# 第 11 章 アカウントの有効化

| 検索キー | パスワード・トークン |   ダイジェスト    |                認証                |
| :------: | :------------------: | :---------------: | :--------------------------------: |
|  email   |       password       |  password_digest  |       authenticate(password)       |
|    id    |    remember_token    |  remember_digest  |  authenticated?(:remember, token)  |
|  email   |   activation_token   | activation_digest | authenticated?(:activation, token) |
|  email   |     reset_token      |   reset_digest    |   authenticated?(:reset, token)    |

# 11.1 AccountActications リソース

# 11.1.1 AccountActivations コントローラ

- `$ rails g controller AccountActivations`を実行<br>

## リスト 11.1: アカウント有効化に使うリソース（`edit` アクション）を追加する

- `config/routes.rb`を編集<br>

```rb:routes.rb
Rails.application.routes.draw do
  get 'sessions/new'
  root 'static_pages#home'
  get '/help', to: 'static_pages#help'
  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
  get '/signup', to: 'users#new'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  resources :users
  resources :account_activations, only: %i[edit]
end
```

`edit_account_activation GET /account_activations/:id/edit(.:format) account_activations#edit`<br>

# 11.1.2 AccountActivation のデータモデル

+ `$ rails g migration add_activation_to_users activation_digest:string activated:boolean activated_at:datetime`を実行<br>

## リスト 11.2: アカウント有効化用の属性とインデックスを追加するマイグレーション

+ `db/migrate/add_activation_to_users.rb`を編集<br>

```rb:add_activation_to_users.rb
class AddActivationToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :activation_digest, :string
    add_column :users, :activated, :boolean, default: false # 編集
    add_column :users, :activated_at, :datetime
  end
end
```

+ `$ rails db:migrate`を実行<br>

## リスト 11.3: Userモデルにアカウント有効化のコードを追加する(GREEN)

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token
  before_save   :downcase_email # 編集
  before_create :create_activation_digest # 追加
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

  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  # 追加
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
  # ここまで
end
```

<h4>サンプルユーザーの生成とテスt</h4><br>

## リスト 11.4: サンプルユーザーを最初から有効にしておく

+ `db/seeds.rb`を編集<br>

```rb:seeds.rb
# メインのサンプルユーザーを1人作成する
User.create!(name:  "Takaki Nakamura",
             email: "takaki55730317@gmail.com",
             password:               "password123",
             password_confirmation:  "password123",
             admin: true,
             # 追加
             activated: true,
             # 追加
             activated_at: Time.zone.now)

# 追加のユーザーをまとめて生成する
99.times do |n|
  name    = Faker::Name.name
  email   = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password,
               # 追加
               activated: true,
               # 追加
               activated_at: Time.zone.now)
end
```

## リスト 11.5: fixtureのユーザーを有効にしておく

+ `test/fixtures/users.yml`を編集<br>

```yml:users.yml
michael:
  name: michael Example
  email: michael@example.com
  password_digest: <%=  User.digest('password') %>
  admin: true
  activated: true # 追加
  activated_at: <%= Time.zone.now %> # 追加

archer:
  name: Sterling Archer
  email: duchess@example.gov
  password_digest: <%= User.digest('password') %>
  activated: true # 追加
  activated_at: <%= Time.zone.now %> # 追加

lana:
  name: Lana Kane
  email: hands@example.gov
  password_digest: <%= User.digest('password') %>
  activated: true # 追加
  activated_at: <%= Time.zone.now %> # 追加

malory:
  name: Malory Archer
  email: boss@example.gov
  password_digest: <%= User.digest('password') %>
  activated: true # 追加
  activated_at: <%= Time.zone.now %> # 追加

<% 30.times do |n| %>
user_<%= n %>:
  name:  <%= "User #{n}" %>
  email: <%= "user-#{n}@example.com" %>
  password_digest: <%= User.digest('password') %>
  activated: true # 追加
  activated_at: <%= Time.zone.now %> # 追加
<% end %>
```

+ `rails db:migrate:reset`を実行<br>

+ `rails db:seed`を実行<br>

# 11.2 アカウント有効化のメール送信

## 11.2.1 送信メールのテンプレート

## リスト 11.6: Userメイラーの生成

+ `$ rails g mailer UserMailer account_activation password_reset`を実行<br>

+ `app/views/user_mailer/account_activation.text.erb`<br>

## リスト　11.7: アカウント有効化メイラーのテキストビュー （自動生成）

```text:account_activation.text.erb
User#account_activation

<%= @greeting %>, find me in app/views/user_mailer/account_activation.text.erb
```

## リスト 11.8: アカウント有効化メイラーのHTMLビュー（自動生成）

+ `app/views/user_mailer/account_activation.html.erb`<br>

```html:account_activation.html.erb
<h1>User#account_activation</h1>

<p>
  <%= @greeting %>, find me in app/views/user_mailer/account_activation.html.erb
</p>
```

## リスト 11.9: Applicationメイラー

+ `app/mailers/application_mailer.rb`<br>

```rb:application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end
```

## リスト 11.10: 生成されたUserメイラー

+ `app/mailers/user_mailer.rb`<br>

```rb:user_mailer.rb
class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject
  #
  def account_activation
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
```

## リスト 11.11: `fron`アドレスのデフォルト値を更新したアプリケーションメイラー

+ `app/mailers/application_mailer.rb`を編集<br>

```rb:application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@example.com' # 編集
  layout 'mailer'
end
```

## リスト11.12: アカウント有効化リンクをメール送信する(RED)

+ `app/mailers/user_mailer.rb`を編集<br>

```rb:user_mailer.rb
class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject
  #
  def account_activation(user) # 編集
    # 編集
    @user = user
    mail to: user.email, subject: "Account activation"
    # ここまで
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
```

## リスト 11.13: アカウント有効化のテキストビュー

+ `app/views/user_mailer/account_activation.text.erb`を編集<br>

```text:acctount_activation.text.erb
Hi <%= @user.name %>.

Welcome to the Sample App! Click on the link below to activate your account:

<%= edit_account_activation_url(@user.activation_token, email: @user.email) %>
```

## リスト 11.14: アカウント有効化のHTMLビュー

+ `app/views/user_mailer/account_activation.html.erb`を編集<br>

```html:account_activation.html.erb
<h1>Sample App</h1>

<p>Hi <%= @user.name %>.</p>

<p>
  Welcome to the Sample App! Click on the link below to activate your account:
</p>

<%= link_to "Activate", edit_account_activation_url(@user.activation_token, email: @user.email) %>
```

## 11.2.2 送信メールのプレビュー

## リスト 11.16: development環境のメール設定

+ `config/environments/development.rb`を編集<br>

```rb:development.rb
require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  host = 'localhost:3200' # 追加

  config.action_mailer.default_url_options = { host: host, protocol: 'http' } # 追加

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true
end
```

# リスト 11.18: アカウント有効化のpレビューメソッド(完成)

+ `test/mailers/previews/user_mailer_preview.rb`を編集<br>

```rb:user_mailer_preview.rb
# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/account_activation
  def account_activation
    # 編集
    user = User.first
    user.activation_token = User.new_token
    UserMailer.account_activation(user)
    # ここまで
  end

  # Preview this email at http://localhost:3200/rails/mailers/user_mailer/password_reset
  def password_reset
    UserMailer.password_reset
  end

end
```

# 11.2.3 送信メールのテスト

## リスト 11.19: Userメイラーのテスト（Railsによる自動生成) RED

```rb:user_mailer_test.rb
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "account_activation" do
    mail = UserMailer.account_activation
    assert_equal "Account activation", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "password_reset" do
    mail = UserMailer.password_reset
    assert_equal "Password reset", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
```

## リスト 11.20: 現在のメールの実装をテストする(RED)

+ `rest/mailers/user_mailer_test.rb`を編集<br>

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
end
```

## リスト 11.21: テストのドメインホストを設定する (GREEN)

+ `config/environments/test.rb`を編集<br>

```rb:test.rb
require "active_support/core_ext/integer/time"

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.cache_classes = false
  config.action_view.cache_template_loading = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory.
  config.active_storage.service = :test

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { host: 'localhost:3200' } # 追加

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true
end
```

+ `$ rails test:mailers`を実行(GREEN)<br>

# 11.2.4 ユーザーの`create`アクションを更新

## リスト 11.23: ユーザー登録にアカウント有効化を追加する (RED)

+ `app/controllers/users_controller.rb`を編集<br>

```rb:users_controller.rb
class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # 編集
      UserMailer.account_activation(@user).deliver_now
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
      # ここまで
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

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  # 管理者かどうか確認
  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end
```

## リスト 11.24: 失敗するテストを一時的にコメントアウトする (GREEN)

+ `test/integration/users_signup_test.rb`を編集<br>

```rb:users_signup_test.rb
require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: {  name: "",
                                          email: "user@invelid",
                                          password:               "foo",
                                          password_confirmation:  "bar" } }
    end
    assert_template 'users/new'
  end

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: {  name: "Example User",
                                          email: "user@example.com",
                                          password:              "password",
                                          password_confirmation: "password" } }
    end
    follow_redirect!
    # コメントアウトする
    # assert_template 'users/show'
    # assert is_logged_in?
  end
end
```

## リスト 11.25: サーバーログに表示されたアカウント有効化メールの例

```
UserMailer#account_activation: processed outbound mail in 49.7ms
rails-web                  | Delivered mail 629059f1be94b_f3faa1601318c56343@8373dc72e77f.mail (19.9ms)
rails-web                  | Date: Fri, 27 May 2022 04:56:17 +0000
rails-web                  | From: noreply@example.com
rails-web                  | To: takaproject777@gmail.com
rails-web                  | Message-ID: <629059f1be94b_f3faa1601318c56343@8373dc72e77f.mail>
rails-web                  | Subject: Account activation
rails-web                  | Mime-Version: 1.0
rails-web                  | Content-Type: multipart/alternative;
rails-web                  |  boundary="--==_mimepart_629059f1bc51b_f3faa1601318c562da";
rails-web                  |  charset=UTF-8
rails-web                  | Content-Transfer-Encoding: 7bit
rails-web                  |
rails-web                  |
rails-web                  | ----==_mimepart_629059f1bc51b_f3faa1601318c562da
rails-web                  | Content-Type: text/plain;
rails-web                  |  charset=UTF-8
rails-web                  | Content-Transfer-Encoding: 7bit
rails-web                  |
rails-web                  | Hi Naomi Etsui.
rails-web                  |
rails-web                  | Welcome to the Sample App! Click on the link below to activate your account:
rails-web                  |
rails-web                  | http://localhost:3200/account_activations/3RfYSs4_tYvG4L0U3CE89A/edit?email=takaproject777%40gmail.com
rails-web                  |
rails-web                  |
rails-web                  | ----==_mimepart_629059f1bc51b_f3faa1601318c562da
rails-web                  | Content-Type: text/html;
rails-web                  |  charset=UTF-8
rails-web                  | Content-Transfer-Encoding: 7bit
rails-web                  |
rails-web                  | <!DOCTYPE html>
rails-web                  | <html>
rails-web                  |   <head>
rails-web                  |     <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
rails-web                  |     <style>
rails-web                  |       /* Email styles need to be inline */
rails-web                  |     </style>
rails-web                  |   </head>
rails-web                  |
rails-web                  |   <body>
rails-web                  |     <h1>Sample App</h1>
rails-web                  |
rails-web                  | <p>Hi Naomi Etsui.</p>
rails-web                  |
rails-web                  | <p>
rails-web                  |   Welcome to the Sample App! Click on the link below to activate your account:
rails-web                  | </p>
rails-web                  |
rails-web                  | <a href="http://localhost:3200/account_activations/3RfYSs4_tYvG4L0U3CE89A/edit?email=takaproject777%40gmail.com">Activate</a>
rails-web                  |
rails-web                  |   </body>
rails-web                  | </html>
rails-web                  |
rails-web                  | ----==_mimepart_629059f1bc51b_f3faa1601318c562da--
```

# 11.3 アカウントを有効化する

## リスト 11.26: 抽象化された`authenticated?`メソッド(RED)

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token
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

  # 編集
  # トークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

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

+ `$ rails test`を実行(RED)

## リスト 11.28: `current_user`内の抽象化した`authenticated?`メソッド(RED)

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

  # 編集
  # 記憶トークンcookieに対応するユーザーを返す（いる場合）
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

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

  # 記憶したURL（もしくはデフォルト値）にリダイレクト
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # アクセスしようとしたURLを覚えておく
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
```

## リスト 11.29: Userテスト内の抽象化した`authenticated?`メソッド(GREEN)

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

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '') # 編集
  end
end
```

## リスト 11.30: GREEN

+ `$ rails test`を実行(GREEN)<br>
