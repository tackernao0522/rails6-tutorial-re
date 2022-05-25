# 第9章 発展的なログイン機構

## 9.1 Remember me 機能

## 9.1.1 記憶トークンと暗号化

+ `$ rails g migration add_remember_digest_to_users remember_digest:string`を実行<br>

+ `$ rails db:migrate`を実行<br>

+ `$ rails console`を実行<br>

+ `irb(main):001:0> SecureRandom.urlsafe_base64`を実行<br>

```:results
=> "cwJ-HIPGDg1G5a-rB2eRxg"
```

## リスト 9.2: トークン生成用メソッドを追加する

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # 追加
  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end
end
```

## リスト 9.3: `remember`メソッドをUserモデルに追加する (GREEN)

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  attr_accessor :remember_token # 追加
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 追加
  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
end
```

## 9.1.2 ログイン状態の保持

## リスト 9.6: `authenticated?` をUserモデルに追加する

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  attr_accessor :remember_token
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 追加
  # 渡されたトークンが第ジェクトと一致したらtrueを返す
  def authenticated?(remember_token)
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
end
```

## リスト 9.7: ログインしてユーザーを保持する (RED)

+ `app/controllers/sessions_controller.rb`を編集<br>

```rb:sessions_controller.rb
class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      log_in user # helperメソッドから
      remember user # 追加 Userモデルの rememberメソッド
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end
```

## リスト 9.8: ユーザーを記憶する (GREEN)

+ `app/helpers/sessions_helper.rb`を編集<br>

```rb:sessions_helper.rb
module SessionsHelper

  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  # 追加
  # ユーザーのセッションを永続化する
  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end

  def logged_in?
    !current_user.nil?
  end

  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
end
```

## リスト 9.9 永続的セッションの `current_user`を更新する (RED)

+ `app/helpers/sessions_helper.rb`を編集<br>

```rb:app/helpers/sessions_helper.rb
module SessionsHelper

  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  # ユーザーのセッションを永続的にする
  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 編集
  # 記憶トークンcookieに対応するユーザーを返す
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def logged_in?
    !current_user.nil?
  end

  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
end
```

+ `$ rails test`を実行<br>

```:results
Running via Spring preloader in process 16
Started with run options --seed 15255

 FAIL UsersLoginTest#test_login_with_valid_information_followed_by_logout (2.84s)
        Expected at least 1 element matching "a[href="/login"]", found 0..
        Expected 0 to be >= 1.
        test/integration/users_login_test.rb:34:in `block in <class:UsersLoginTest>'

  22/22: [========] 100% Time: 00:00:03, Time: 00:00:03

Finished in 3.38020s
22 tests, 56 assertions, 1 failures, 0 errors, 0 skips
```

# 9.1.3 ユーザーを忘れる

## リスト 9.11: `forget` メソッドをUserモデルに追加する (RED)

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  attr_accessor :remember_token
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated?(remember_token)
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # 追加
  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end
end
```

## リスト 9.12: 永続セッションからログアウトする (GREEN)

+ `app/helpers/sessions_helper.rb`を編集<br>

```rb:sessions_helper.rb
module SessionsHelper

  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  # ユーザーのセッションを永続的にする
  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 記憶トークンcookieに対応するユーザーを返す
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def logged_in?
    !current_user.nil?
  end

  # 追加
  # 永続的セッションを破棄する
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # 現在のユーザーをログアウトする
  def log_out
    forget(current_user) # 追加
    session.delete(:user_id)
    @current_user = nil
  end
end
```

+ `$ rails test`を実行<br>

```:results
[+] Running 1/0
 ⠿ Container rails-db  Ru...                      0.0s
Running via Spring preloader in process 17
Started with run options --seed 54022

  22/22: [========] 100% Time: 00:00:03, Time: 00:00:03

Finished in 3.50163s
22 tests, 58 assertions, 0 failures, 0 errors, 0 skips
```

# 9.1.4 2つの目立たないバグ

## リスト 9.14: 2番目のウィンドウでユーザーをログアウトするテスト(RED)

+ `test/integration/users_login_test.rb`を編集<br>

```rb:users_login_test.rb
require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "login with valid email/invalid password" do
    get login_path
    post login_path, params: { session: { email: @user.email, password: "invalid" } }
    assert_not is_logged_in?
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "login with valid information followed by logout" do
    get login_path
    post login_path, params: { session: { email: @user.email,
                                          password: 'password' } }
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    # 2番目のウィンドウでログアウトをクリックするユーザーをシミュレートする
    delete logout_path # 追加
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end
end
```

+ `rails test`を実行<br>

```:results
 ⠿ Container rails-db  Ru...                      0.0s
Running via Spring preloader in process 18
Started with run options --seed 11361

ERROR UsersLoginTest#test_login_with_valid_information_followed_by_logout (2.28s)
Minitest::UnexpectedError:         NoMethodError: undefined method `forget' for nil:NilClass
            app/helpers/sessions_helper.rb:33:in `forget'
            app/helpers/sessions_helper.rb:39:in `log_out'
            app/controllers/sessions_controller.rb:18:in `destroy'
            test/integration/users_login_test.rb:33:in `block in <class:UsersLoginTest>'

  22/22: [===================================================================================================] 100% Time: 00:00:03, Time: 00:00:03

Finished in 3.40822s
```

## リスト 9.16: ログイン中の場合のみログアウトする (GREEN)

+ `app/controllers/sessions_controller.rb`を編集<br>

```rb:sessions_controller.rb
class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      log_in user # helperメソッドから
      remember user # helperメソッドから rememberメソッド
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in? # 編集
    redirect_to root_url
  end
end
```

## リスト 9.17: ダイジェストが存在しない場合の `authenticated?`のテスト(RED)

+ `test/models/user_test.rb`を編集<br>

```rb:user_test.rb
require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                    password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = ""
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "    "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
      first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
      foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should be saved ad lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  # 追加
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?('')
  end
end
```

+ `$ rails test`を実行<br>

```:results
[+] Running 1/0
 ⠿ Container rails-db  Ru...                      0.0s
Running via Spring preloader in process 17
Started with run options --seed 63063

ERROR UserTest#test_authenticated?_should_return_false_for_a_user_with_nil_digest (3.27s)
Minitest::UnexpectedError:         BCrypt::Errors::InvalidHash: invalid hash
            app/models/user.rb:28:in `new'
            app/models/user.rb:28:in `authenticated?'
            test/models/user_test.rb:77:in `block in <class:UserTest>'

  23/23: [========] 100% Time: 00:00:03, Time: 00:00:03
```

## リスト 9.19: `authenticated?` を更新して、ダイジェストが存在しない場合に対応(GREEN)

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  attr_accessor :remember_token
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated?(remember_token)
    return false if remember_digest.nil? # 追加
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end
end
```

+ `$ rails test`を実行<br>

```:results
[+] Running 1/0
 ⠿ Container rails-db  Ru...                      0.0s
Running via Spring preloader in process 17
Started with run options --seed 8984

  23/23: [===================================================================================================] 100% Time: 00:00:04, Time: 00:00:04

Finished in 4.47036s
23 tests, 59 assertions, 0 failures, 0 errors, 0 skips
```

# 9.2 [Remember me] チェックボックス

## リスト 9.21: [remember me] チェックボックスをログインフォームに追加する

+ `app/views/sessions/new.html.erb`を編集<br>

```html:new.html.erb
<% provide(:title, "Log in") %>
<h1>Log in</h1>

<div class="row">
  <div class="col-md-6 col-md-offset-3">
    <%= form_with(url: login_path, scope: :session, local: true) do |f| %>
    <%= f.label :email %>
    <%= f.email_field :email, class: 'form-control' %>

    <%= f.label :password %>
    <%= f.password_field :password, class: 'form-control' %>

    <%= f.label :remember_me, class: "checkbox inline" do %>
    <%= f.check_box :remember_me %>
    <span>Remember me on this computer</span>
    <% end %>

    <%= f.submit "Log in", class: "btn btn-primary" %>
    <% end %>

    <p>New user? <%= link_to "Sign up now!", signup_path %></p>
  </div>
</div>
```

## リスト 9.22: [remember me] チェックボックスのCSS

+ `app/assets/stylesheets/custom.scss`を編集<br>

```scss:custom.scss
@import 'bootstrap-sprockets';
@import 'bootstrap';

/* mixins, variables, etc. */

$gray-medium-light: #eaeaea;

@mixin box_sizing {
  -moz-box-sizing: border-box;
  -webkit-box-sizing: border-box;
  box-sizing: border-box;
}

/* universal */

body {
  padding-top: 60px;
}

section {
  overflow: auto;
}

textarea {
  resize: vertical;
}

.center {
  text-align: center;
  h1 {
    margin-bottom: 10px;
  }
}

/* typography */

h1,
h2,
h3,
h4,
h5,
h6 {
  line-height: 1;
}

h1 {
  font-size: 3em;
  letter-spacing: -2px;
  margin-bottom: 30px;
  text-align: center;
}

h2 {
  font-size: 1.2em;
  letter-spacing: -1px;
  margin-bottom: 30px;
  text-align: center;
  font-weight: normal;
  color: $gray-light;
}

p {
  font-size: 1.1em;
  line-height: 1.7em;
}

/* header */

#logo {
  float: left;
  margin-right: 10px;
  font-size: 1.7em;
  color: white;
  text-transform: uppercase;
  letter-spacing: -1px;
  padding-top: 9px;
  font-weight: bold;
  &:hover {
    color: white;
    text-decoration: none;
  }
}

/* footer */

footer {
  margin-top: 45px;
  padding-top: 5px;
  border-top: 1px solid $gray-medium-light;
  color: $gray-light;
  a {
    color: $gray;
    &:hover {
      color: $gray-darker;
    }
  }
  small {
    float: left;
  }
  ul {
    float: right;
    list-style: none;
    li {
      float: left;
      margin-left: 15px;
    }
  }
}

/* miscellaneous */

.debug_dump {
  clear: both;
  float: left;
  width: 100%;
  margin-top: 45px;
  @include box_sizing;
}

/* sidebar */

aside {
  section.user_info {
    margin-top: 20px;
  }
  section {
    padding: 10px 0;
    margin-top: 20px;
    &:first-child {
      border: 0;
      padding-top: 0;
    }
    span {
      display: block;
      margin-bottom: 3px;
      line-height: 1;
    }
    h1 {
      font-size: 1.4em;
      text-align: left;
      letter-spacing: -1px;
      margin-bottom: 3px;
      margin-top: 0px;
    }
  }
}

.gravatar {
  float: left;
  margin-right: 10px;
}

.gravatar_edit {
  margin-top: 15px;
}

/* forms */

input,
textarea,
select,
.uneditable-input {
  border: 1px solid #bbb;
  width: 100%;
  margin-bottom: 15px;
  @include box_sizing;
}

input {
  height: auto !important;
}

#error_explanation {
  color: red;
  ul {
    color: red;
    margin: 0 0 30px 0;
  }
}

.field_with_errors {
  @extend .has-error;
  .form-control {
    color: $state-danger-text;
  }
}

// 追加
.checkbox {
  margin-top: -10px;
  margin-bottom: 10px;
  span {
    margin-left: 20px;
    font-weight: normal;
  }
}

#session_remember_me {
  width: auto;
  margin-left: 0;
}
// ここまで
```

## リスト 9.23: [remember me] チェックボックスの送信結果を処理する

+ `app/controllers/sessions_controller.rb`を編集<br>

```rb:sessions_controller.rb
class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      log_in user # helperメソッドから
      # 編集
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
```

# 9.3 [Remember me] のテスト

## リスト 9.24: `log_in_as`ヘルパーを追加する

+ `test/test_helper.rb`を編集<br>

```rb:test_helper.rb
ENV['RAILS_ENV'] ||= 'test'
require_relative "../config/environment"
require "rails/test_help"

# gem minitest-reporters setup
require 'minitest/reporters'
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include ApplicationHelper

  def is_logged_in?
    !session[:user_id].nil?
  end

  # 追加
  # テストユーザーとしてログインする
  def log_in_as(user)
    session[:user_id] = user.id
  end
end

class ActionDispatch::IntegrationTest
    # テストユーザーとしてログインする
    def log_in_as(user, password: 'password', remember_me: '1')
      post login_path, params: { session: { email: user.email, password: password,
                                            remember_me: remember_me } }
    end
end
# ここまで
```

## リスト 9.25: [remember me] チェックボックスのテスト (GREEN)

+ `test/integration/users_login_test.rb`を編集<br>

```rb:users_login_test.rb
require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "login with valid email/invalid password" do
    get login_path
    post login_path, params: { session: { email: @user.email, password: "invalid" } }
    assert_not is_logged_in?
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "login with valid information followed by logout" do
    get login_path
    post login_path, params: { session: { email: @user.email,
                                          password: 'password' } }
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  # 追加
  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    assert_not_empty cookies[:remember_token]
  end

  test "login without remembering" do
    # cookieを保存してログイン
    log_in_as(@user, remember_me: '1')
    delete logout_path
    # cookieを削除してログイン
    log_in_as(@user, remember_me: '0')
    assert_empty cookies[:remember_token]
  end
  # ここまで
end
```

+ `$ rails test`を実行<br>

```:terminal
ompose run --rm web rails t
[+] Running 1/0
 ⠿ Container rails-db  Ru...                      0.0s
Running via Spring preloader in process 17
Started with run options --seed 33149

  25/25: [========] 100% Time: 00:00:04, Time: 00:00:04

Finished in 4.24833s
25 tests, 63 assertions, 0 failures, 0 errors, 0 skips
```

# 9.3.2 [Remember me] をテストする

## リスト 9.29: テストされていないブランチで例外を発生する (GREEN)

+ `app/helpers/sessions_helper.rb`を編集<br>

```rb:sessions_helper.rb
module SessionsHelper

  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  # ユーザーのセッションを永続的にする
  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 記憶トークンcookieに対応するユーザーを返す
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    elsif (user_id = cookies.encrypted[:user_id])
      raise # 追加 テストがパスすれば、この部分がテストされていないことがわかる
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def logged_in?
    !current_user.nil?
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
end
```

+ `$ rails test`を実行<br>

```:terminal
[+] Running 1/0
 ⠿ Container rails-db  Ru...                      0.0s
Running via Spring preloader in process 17
Started with run options --seed 61897

  25/25: [========] 100% Time: 00:00:04, Time: 00:00:04

Finished in 4.46897s
25 tests, 63 assertions, 0 failures, 0 errors, 0 skips
```

## リスト 9.31: 永続的セッションのテスト(RED)

+ `$ touch test/helpers/sessions_helper_test.rb`を実行<br>

+ `test/helpers/sessions_helper_test.rb`を編集<br>

```rb:sessions_helper_test.rb
require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

  def setup
    @user = users(:michael)
    remember(@user)
  end

  test "current_user returns right user when session is nil" do
    assert_equal @user, current_user
    assert is_logged_in?
  end

  test "current_user returns nil when remember digest is wrong" do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
end
```

## リスト 9.32: RED

+ `$ rails test test/helpers/sessions_helper_test.rb`を実行<br>

```:terminal
[+] Running 1/0
 ⠿ Container rails-db  Ru...                      0.0s
Running via Spring preloader in process 16
Started with run options --seed 41789

DEPRECATED: Use assert_nil if expecting nil from test/helpers/sessions_helper_test.rb:11. This will fail in Minitest 6.
 FAIL SessionsHelperTest#test_current_user_returns_right_user_when_session_is_nil (0.44s)
        Expected false to be truthy.
        test/helpers/sessions_helper_test.rb:12:in `block in <class:SessionsHelperTest>'

ERROR SessionsHelperTest#test_current_user_returns_nil_when_remember_digest_is_wrong (0.46s)
Minitest::UnexpectedError:         NoMethodError: undefined method `update_attribute' for nil:NilClass
            test/helpers/sessions_helper_test.rb:16:in `block in <class:SessionsHelperTest>'

  2/2: [==========] 100% Time: 00:00:00, Time: 00:00:00

Finished in 0.60914s
2 tests, 2 assertions, 1 failures, 1 errors, 0 skips
```

## リスト 9.33: 例外発生部分を削除する (GREEN)

+ `app/helpers/sessions_helper.rb`を編集<br>

```rb:sessions_helper.rb
module SessionsHelper

  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  # ユーザーのセッションを永続的にする
  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 記憶トークンcookieに対応するユーザーを返す
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    elsif (user_id = cookies.encrypted[:user_id])
      # raiseを削除
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def logged_in?
    !current_user.nil?
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
end
```

+ `$ rails test`を実行<br>

```:terminal
[+] Running 1/0
 ⠿ Container rails-db  Ru...                      0.0s
Running via Spring preloader in process 17
Started with run options --seed 1216

  27/27: [========] 100% Time: 00:00:03, Time: 00:00:03

Finished in 3.46567s
27 tests, 66 assertions, 0 failures, 0 errors, 0 skips
```
