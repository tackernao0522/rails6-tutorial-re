# 第12章 パスワードの再設定

## 12.1 PasswordResetsリソース

## 12.1.1 PasswordResetsコントローラ

+ `$ rails g controller PasswordResets new edit --no-test-framework`を実行<br>

## リスト 12.1: パスワード再設定用リソースを追加する

+ `config/routes.rb`を編集<br>

```rb:routes.rb
Rails.application.routes.draw do
  get 'password_resets/new'
  get 'password_resets/edit'
  get 'sessions/new'
  root 'static_pages#home'
  get '/help',     to: 'static_pages#help'
  get '/about',    to: 'static_pages#about'
  get '/contact',  to: 'static_pages#contact'
  get '/signup',   to: 'users#new'
  get '/login',    to: 'sessions#new'
  post '/login',   to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  resources :users
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
end
```

routes list<br>

```
password_resets     POST   /password_resets(.:format)                 password_resets#create
new_password_reset  GET    /password_resets/new(.:format)             password_resets#new
edit_password_reset GET    /password_resets/:id/edit(.:format)        password_resets#edit
password_reset      PATCH  /password_resets/:id(.:format)             password_resets#update
                    PUT    /password_resets/:id(.:format)             password_resets#update
```

## リスト 12.2: パスワード再設定画面へのリンクを追加する

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
    <%= link_to "(forgot password)", new_password_reset_path %>
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

## 12.1.2 新しいパスーワードの設定

### users table

|Column|Type|
|:---:|:---:|
|id|integer|
|name|string|
|email|string|
|created_at|datetime|
|updated_at|datetime|
|password_digest|string|
|remember_digest|string|
|admin|boolean|
|activation_digest|string|
|activated|boolean|
|activated_at|datetime|
|reset_digest|string|
|reset_sent_at|datetime|


+ `$ rails g migration add_reset_to_users reset_digest:string reset_sent_at:datetime`を実行<br>

+ `$ rails db:migrate`を実行<br>

## リスト 12.4: 新しいパスワード再設定画面ビュー

+ `app/views/password_resets/new.html.erb`を編集<br>

```html:new.html.erb
<% provide(:title, "Forgot password") %>
<h1>Forgot password</h1>

<div class="row">
  <div class="col-md-6 col-md-offset-3">
    <%= form_with(url: password_resets_path, scope: :password_reset, local: true) do |f| %>
    <%= f.label :email %>
    <%= f.email_field :email, class: 'form-control' %>

    <%= f.submit "Submit", class: "btn btn-primary" %>
    <% end %>
  </div>
</div>
```

# 12.1.3 `create`アクションでパスワード再設定

## リスト 12.5: パスワード再設定用の`create`アクション

+ `app/controllers/password_resets_controller.rb`を編集<br>

```rb:password_resets_controller.rb
class PasswordResetsController < ApplicationController
  def new
  end

  # 追加
  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end
  # ここまで

  def edit
  end
end
```

## リスト 12.6: Userモデルにパスワード再設定用メソッドを追加する

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token # 追加
  before_save   :downcase_email
  before_create :create_activation_digest
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
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

  # トークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # 追加
  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end
  # ここまで

  private

  # メールアドレスをすべて小文字にする
  def downcase_email
    self.email = email.downcase
  end

  # 有効化トークンとダイジェストを作成及び代入する
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
```

# 12.2.1 パスワード再設定のメールとテンプレート

+ `app/mailers/user_mailer.rb`を編集<br>

```rb:user_mailer.rb
class UserMailer < ApplicationMailer

  def account_activation(user)
    @user = user
    mail to: user.email, subject: "Account activation"
  end

  # 編集
  def password_reset(user)
    @user = user

    mail to: user.email, subject: "Password reset"
  end
  # ここまで
end
```

## リスト 12.8: パスワード再設定のテンプレート(テキスト)

+ `app/views/user_mailer/password_reset.text.erb`を編集<br>

```html:password_reset.text.erb
To reset your password click the link below:

<%= edit_password_reset_url(@user.reset_token, email: @user.email) %>

This link will expire in two hours.

If you did not request your password to be reset, please igonore this email and your password will stay as it is.
```

## リスト 12.9: パスワード再設定のテンプレート(HTML)

+ `app/views/user_mailer/password_reset.html.erb`を編集<br>

```html:password_reset.html.erb
<h1>Password reset</h1>

<p>To reset your password click the link below:</p>

<%= link_to "Reset password", edit_password_reset_url(@user.reset_token, email: @user.email) %>

<p>This link will expire in two hours.</p>

<p>
  If you did not request your password to be reset, please ignore this email and your password will stay as it is.
</p>
```

## リスト 12.10: パスワード再設定のプレビューメソッド(完成)

+ `test/mailers/previews/user_mailer_preview.rb`を編集<br>

```rb:user_mailer_preview.rb
# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3200/rails/mailers/user_mailer/account_activation
  # http://localhost:3200/rails/mailers/user_mailer/account_activation
  def account_activation
    user = User.first
    user.activation_token = User.new_token
    UserMailer.account_activation(user)
  end

  # Preview this email at http://localhost:3200/rails/mailers/user_mailer/password_reset
  # http://localhost:3200/rails/mailers/user_mailer/password_reset
  # 編集
  def password_reset
    user = User.first
    user.reset_token = User.new_token
    UserMailer.password_reset(user)
  end

end
```

# 12.2.2 送信メールのテスト

## リスト 12.12: パスワード再設定用メイラーメソッドのテストを追加する(GREEN)

+ `test/mailers/user_mailer_test.rb`を編集<br>

```rb:user_mailer_test.rb
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "account_activation" do
    user = users(:michael)
    user.activation_token = User.new_token
    mail = UserMailer.account_activation(user)
    assert_equal "Account activation", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
    assert_match user.name,               mail.body.encoded
    assert_match user.activation_token,   mail.body.encoded
    assert_match CGI.escape(user.email),  mail.body.encoded
  end

  # 追加
  test "password_reset" do
    user = users(:michael)
    user.reset_token = User.new_token
    mail = UserMailer.password_reset(user)
    assert_equal "Password reset", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
    assert_match user.reset_token,        mail.body.encoded
    assert_match CGI.escape(user.email),  mail.body.encoded
  end
end
```

+ `$ rails test`を実行(GREEN)

# 12.3 パスワードを再設定する

## 12.3.1 `edit`アクションで再設定

## リスト 12.14: パスワード再設定フォーム

+ `app/views/password_resets/edit.html.erb`を編集<br>

```html:edit.html.erb
<% provide(:title, 'Reset password') %>
<h1>Reset password</h1>

<div class="row">
  <div class="col-md-6 col-md-offset-3">
    <%= form_with(model: @user, url: password_reset_path(params[:id]), local: true) do |f| %>
    <%= render 'shared/error_messages' %>

    <%= hidden_field_tag :email, @user.email %>

    <%= f.label :password %>
    <%= f.password_field :password, class: 'form-control' %>

    <%= f.label :password_confirmation, "Confirmation" %>
    <%= f.password_field :password_confirmation, class: 'form-control' %>

    <%= f.submit "Update password", class: "btn btn-primary" %>
    <% end %>
  </div>
</div>
```

## リスト 12.15: パスワード再設定の`edit`アクション

+ `app/controllers/password_resets_controller.rb`を編集<br>

```rb:password_resets_controller.rb
class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update] # 追加
  before_action :valid_user, only: [:edit, :update] # 追加

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def edit
  end

  # 追加
  private

  def get_user
    @user = User.find_by(email: params[:email])
  end

  # 正しいユーザーかどうか確認する
  def valid_user
    unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
      redirect_to root_url
  end
  # ここまで
end
```

# 12.3.2 パスワードを更新する

## リスト 12.16: パスワード再設定の`update`アクション

+ `app/controllers/password_resets_controller.rb`を編集<br>

```rb:password_resets_controller.rb
class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update] # 追加 (1)への対応

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def edit
  end

  # 追加
  def update
    if params[:user][:password].empty? # (3)への対応
      @user.errors.add(:password, :blank)
      render 'edit'
    elsif @user.update(user_params) # (4)への対応
      log_in @user
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit' # (2)への対応
    end
  end

  private

  # 追加
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    @user = User.find_by(email: params[:email])
  end

  # 正しいユーザーかどうか確認する
  def valid_user
    unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
      redirect_to root_url
    end
  end

  # 追加
  # トークンが期限切れかどうか確認する
  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = "Password reset has expired."
      redirect_to new_password_reset_url
    end
  end
end
```

## リスト 12.17: Userモデルにパスワード再設定用メソッドを追加する

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save   :downcase_email
  before_create :create_activation_digest
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
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

  # トークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # 追加
  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  private

  # メールアドレスをすべて小文字にする
  def downcase_email
    self.email = email.downcase
  end

  # 有効化トークンとダイジェストを作成および代入する
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
```

# 12.3.3 パスワードの再設定をテストする

+ `$ rails g integration_test password_resets`を実行<br>

## 12.18: パスワード再設定の統合テスト

+ `test/integration/password_resets_test.rb`を編集<br>

```rb:password_resets_test.rb
require "test_helper"

class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password resets" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
    # メールアドレスが無効
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_not flash.empty?
    assert_template 'password_resets/new'
    # メールアドレスが有効
    post password_resets_path, params: { password_reset: { email: @user.email  } }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    # パスワード再設定フォームのテスト
    user = assigns(:user)
    # メールアドレスが無効
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
    # 無効なユーザー
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    # メールアドレスが有効で、トークンが無効
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url
    # メールアドレスもトークンも有効
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email
    # 無効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:      "foobaz",
                    password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'
    # パスワードが空
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "",
                            password_confirmation: "" } }
    assert_select 'div#error_explanation'
    # 有効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "foobaz" } }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end
end
```

+ `$ rails test`を実行(GREEN)

