# 第 10 章 ユーザーの更新・表示・削除

## 10.1 ユーザーを更新する

## 10.1.1 編集フォーム

## リスト 10.1: ユーザーの`edit`アクション

+ `app/controllers/users_controller.rb`を編集<br>

```rb:users_controller.rb
class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end

  end

  def edit
    @user = User.find(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
```

## リスト 10.2: ユーザーのeditビュー

+ `$ touch app/views/users/edit.html.erb`を実行<br>

+ `app/views/users/edit.html.erb`を編集<br>

```html:edit.html.erb
<% provide(:title, "Edit user") %>
<h1>Update your profile</h1>

<div class="row">
  <div class="col-md-6 col-md-offset-3">
    <%= form_with(model: @user, local: true) do |f| %>
      <%= render 'shared/error_messages' %>
      <%= f.label :name %>
      <%= f.text_field :name, class: 'form-control' %>
      <%= f.label :email %>
      <%= f.email_field :email, class: 'form-control' %>
      <%= f.label :password %>
      <%= f.password_field :password, class: 'form-control' %>
      <%= f.label :password_confirmation, "Confirmation" %>
      <%= f.password_field :password_confirmation, class: 'form-control' %>
      <%= f.submit "Save changes", class: "btn btn-primary" %>
    <% end %>

    <div class="gravatar_edit">
      <%= gravatar_for @user %>
      <a href="https://gravatar.com/emails" target="_blank">change</a>
    </div>
  </div>
</div>
```

## リスト 10.4: レイアウトの "Settings" リンクを更新する

+ `app/views/layouts/_header.html.erb`を編集<br>

```html:_header.html.erb
<header class="navbar navbar-fixed-top navbar-inverse">
  <div class="container">
    <%= link_to "sample app", root_path, id: "logo" %>
    <nav>
      <ul class="nav navbar-nav navbar-right">
        <li><%= link_to "Home",   root_path %></li>
        <li><%= link_to "Help",   help_path %></li>
        <% if logged_in? %>
        <li><%= link_to "Users", '#' %></li>
        <li class="dropdown">
          <a href="#" class="dropdown-toggle" data-toggle="dropdown">
            Account <b class="caret"></b>
          </a>
          <ul class="dropdown-menu">
            <li><%= link_to "Profile", current_user %></li>
            <!-- 編集 -->
            <li><%= link_to "Settings", edit_user_path(current_user) %></li>
            <li class="divider"></li>
            <li>
              <%= link_to "Logout", logout_path, method: :delete %>
            </li>
          </ul>
        </li>
        <% else %>
        <li><%= link_to "Log in", login_path %></li>
        <% end %>
      </ul>
    </nav>
  </div>
</header>
```

## 10.1.2 編集の失敗

## リスト 10.8: ユーザーの `update` アクションの初期実装

+ `app/controllers/users_controller.rb`を編集<br>

```rb:controllers/users_controller.rb
class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end

  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
```

## 10.1.3 編集失敗時のテスト

+ `$ rails g integration_test users_edit`を実行<br>

## リスト 10.9: 編集の失敗に対するテスト (GREEN)

+ `test/integration/users_edit_test.rb`を編集<br>

```rb:users_edit_test.rb
require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "unsuccessful edit" do
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name: "",
                                              email: "foo@invalid",
                                              password:               "foo",
                                              password_confirmation:  "bar" } }
    assert_template 'users/edit'
  end
end
```

+ `rails test`を実行<br>

```:terminal
Running via Spring preloader in process 137
Started with run options --seed 5896

  28/28: [========] 100% Time: 00:00:03, Time: 00:00:03

Finished in 3.77305s
28 tests, 68 assertions, 0 failures, 0 errors, 0 skips
```

# 10.1.4 TDDで編集を成功させる

## リスト 10.11: 編集の成功に対するテスト (RED)

+ `test/integration/users_edit_test.rb`を編集<br>

```rb:users_edit_test.rb
require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "unsuccessful edit" do
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name: "",
                                              email: "foo@invalid",
                                              password:               "foo",
                                              password_confirmation:  "bar" } }
    assert_template 'users/edit'
  end

  test "successful edit" do
    get edit_user_path(@user)
    assert_template 'users/edit'
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name: name,
                                             email: email,
                                             password:         "",
                                             password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end
end
```

## リスト 10.12: ユーザーの `update`アクション (RED)

+ `app/controllers/users_controller.rb`を編集<br>

```rb:users_controller.rb
class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end

  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      # 追加
      flash[:success] = "Profile updated"
      redirect_to @user
      # ここまで
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
```

## リスト 10.13: パスワードが空のままでも更新できるようにする (GREEN)

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
  # 編集
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

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
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end
end
```

+ `$ rails test`を実行<br>

```:terminal
Running via Spring preloader in process 183
Started with run options --seed 8752

  29/29: [========] 100% Time: 00:00:03, Time: 00:00:03

Finished in 3.42818s
29 tests, 74 assertions, 0 failures, 0 errors, 0 skips
```

# 10.2 認可

## 10.2.1 ユーザーにログインを要求する

## リスト 10.15: beforeフィルターに `logged_in_user`を追加する (RED)

+ `app/controllers/users_controller.rb`を編集<br>

```rb:users_controller.rb
class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update] # 追加

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end

  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # 追加
  def logged_in_user
    unless logged_in?
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end
end
```

+ `$ rails test`を実行<br>

```:terminal
Running via Spring preloader in process 208
Started with run options --seed 8829

 FAIL UsersEditTest#test_successful_edit (2.03s)
        expecting <"users/edit"> but rendering with <[]>
        test/integration/users_edit_test.rb:21:in `block in <class:UsersEditTest>'

 FAIL UsersEditTest#test_unsuccessful_edit (2.05s)
        expecting <"users/edit"> but rendering with <[]>
        test/integration/users_edit_test.rb:11:in `block in <class:UsersEditTest>'

  29/29: [========] 100% Time: 00:00:03, Time: 00:00:03

Finished in 3.28676s
29 tests, 68 assertions, 2 failures, 0 errors, 0 skips
```

## リスト 10.17: テストユーザーでログインする (GREEN)

+ `test/integration/users_edit_test.rb`を編集<br>

```rb:users_edit_test.rb
require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "unsuccessful edit" do
    log_in_as(@user) # test_helperから
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name: "",
                                              email: "foo@invalid",
                                              password:               "foo",
                                              password_confirmation:  "bar" } }
    assert_template 'users/edit'
  end

  test "successful edit" do
    log_in_as(@user) # test_helperから
    get edit_user_path(@user)
    assert_template 'users/edit'
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name: name,
                                              email: email,
                                              password:         "",
                                              password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end
end
```

+ `rails test`を実行(GREEN)<br>

## リスト 10.19: セキュリティモデルを確認するためにbeforeフィルターをコメントアウトする(GREEN)

+ `app/controllers/users_controller.rb`を編集<br>

```rb:users_controller.rb
class UsersController < ApplicationController
  # コメンアウトする
  # before_action :logged_in_user, only: [:edit, :update]

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end

  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def logged_in_user
    unless logged_in?
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end
end
```

## リスト 10.20: `edit`と`update`アクションの保護に対するテストする(RED)

+ `test/controllers/users_controller_test.rb`を編集<br>

```rb:users_controller_test.rb
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end
end
```

+ `$ rails test`を実行(RED)<br>

## リスト 10.21: beforeフィルターを再び有効化する(GREEN)

+ `app/controllers/users_controller.rb`を編集<br>

```rb:users_controller.rb
class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update] # コメントアウトを解除

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end

  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def logged_in_user
    unless logged_in?
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end
end
```

+ `$ rails test`を実行(GREEN)<br>

# 10.2.2 正しいユーザーを要求する

## リスト 10.23: fixtureファイルに2人目のユーザーを追加する

+ `test/fixtures/users.yml`を編集<br>

```yml:users.yml
michael:
  name: michael Example
  email: michael@example.com
  password_digest: <%=  User.digest('password') %>

# 追加
archer:
  name: Sterling Archer
  email: duchess@example.gov
  password_digest: <%= User.digest('password') %>
```

## リスト 10.24: 間違ったユーザーが編集しようとしたときのテスト(RED)

+ `test/controllers/users_controller_test.rb`を編集<br>

```rb:users_controller_test.rb
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user       = users(:michael)
    @other_user = users(:archer)
  end

  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  # 追加
  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: {  name: @user.name,
                                              email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end
  # ここまで
end
```

## リスト 10.25: beforeフィルターを使って編集/更新ページを保護する(GREEN)

+ `app/controllers/users_controller.rb`を編集<br>

```rb:users_controller.rb
class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update]
  before_action :correct_user,   only: [:edit, :update] # 追加

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end

  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def logged_in_user
    unless logged_in?
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  # 追加
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless @user == current_user
  end
end
```

+ `$ rails test`を実行(GREEN)<br>

## リスト 10.27: `current_user?`メソッド

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

  # 追加
  # 渡されたユーザーがカレンとユーザーであればtrueを返す
  def current_user?(user)
    user && user == current_user
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

## リスト10.28: 最終的な`correct_user`の実装(GREEN)

+ `app/controllers/users_controller.rb`を編集<br>

```rb:users_controller.rb
class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update]
  before_action :correct_user,   only: [:edit, :update]

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end

  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def logged_in_user
    unless logged_in?
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user) # 編集
  end
end
```