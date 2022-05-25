# 第 8 章 基本的なログイン機構

# 8.1 セッション

## リスト 8.1: Sessionsコントローラを生成する

+ `$ rails g controller Sessions new`を実行<br>

## リスト 8.2: リソースを追加して標準的なRESTfulアクションをgetできるようにする(RED)

+ `config/routes.rb`を編集<br>

```rb:routes.rb
Rails.application.routes.draw do
  get 'sessions/new'
  root 'static_pages#home'
  get '/help',     to: 'static_pages#help'
  get '/about',    to: 'static_pages#about'
  get '/contact',  to: 'static_pages#contact'
  get '/signup',   to: 'users#new'
  # 追加
  get '/login',    to: 'sessions#new'
  post '/login',   to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  # ここまで
  resources :users
end
```

## リスト8.3: Sessionsコントローラのテストで名前付きルートを使うようにする(GREEN)

+ `test/controllers/sessions_controller_test.rb`を編集<br>

```rb:sessions_controller_test.rb
require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get login_path
    assert_response :success
  end
end
```

## リスト 8.4: ログインフォームのコード

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

    <%= f.submit "Log in", class: "btn btn-primary" %>
    <% end %>

    <p>New user? <%= link_to "Sign up now!", signup_path %></p>
  </div>
</div>
```

# 8.1.3 ユーザーの検索と認証

## リスト 8.6: Sessionsコントローラの`create`アクション(暫定版)

+ `app/controllers/sessions_controller.rb`を編集<br>

```rb:sessions_controller.rb
class SessionsController < ApplicationController
  def new
  end

  def create
    render 'new'
  end

  def destroy

  end
end
```

## リスト 8.7: ユーザーをデータベースから見つけて検証する

+ `app/controllers/sessions_controller.rb`を編集<br>

```rb:sessions_controller.rb
class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
    else
      render 'new'
    end
  end
  # エラーメッセージを作成する
  def destroy

  end
end
```

# 8.1.4 フラッシュメッセージを表示する

## リスト 8.8: ログイン失敗時の処理を扱う(誤りあり)

+ `app/controllers/sessions_controller.rb`を編集<br>

```rb:sessions_controller.rb
class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
    else
      flash[:danger] = 'Invalid email/password combination' # 本当は正しくない
      render 'new'
    end
  end
  # エラ〜メッセージを作成する
  def destroy

  end
end
```

+ わざとログイン失敗してみるとフラッシュメッセージが出るがそのままどこかのページへ遷移してもフラッシュメーッセージが残ったままになってしまう<br>

# 8.1.5 フラッシュのテスト

+ `$ rails g integration_test users_login`を実行<br>

## リスト 8.9: フラッシュメッセージの残留をキャッチするテスト(RED)

+ `test/integration/users_login_test.rb`を編集<br>

```rb:users_login_test.rb
require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest

  test "login with invalid information" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: "", password: "" } }
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end
end
```

+ `$ rails test test/integration/users_login_test.rb`を実行<br>

```:terminal
[+] Running 1/0
 ⠿ Container rails-db  Ru...                      0.0s
Running via Spring preloader in process 18
Started with run options --seed 48220

 FAIL UsersLoginTest#test_login_with_invalid_information (1.25s)
        Expected false to be truthy.
        test/integration/users_login_test.rb:12:in `block in <class:UsersLoginTest>'

  1/1: [==========] 100% Time: 00:00:01, Time: 00:00:01

Finished in 1.32608s
1 tests, 4 assertions, 1 failures, 0 errors, 0 skips
```

## リスト 8.11: ログイン失敗時の正しい処理(GREEN)

+ `app/controllers/sessions_controller.rb`を編集<br>

```rb:sessions_controller.rb
class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
    else
      flash.now[:danger] = 'Invalid email/password combination' # 編集
      render 'new'
    end
  end
  # エラ〜メッセージを作成する
  def destroy

  end
end
```

+ `app/controllers/sessions_controller.rb`を編集<br>

```:terminal
[+] Running 1/0
 ⠿ Container rails-db  Ru...                      0.0s
Running via Spring preloader in process 18
Started with run options --seed 42237

  1/1: [=====================================================================================================] 100% Time: 00:00:01, Time: 00:00:01

Finished in 1.14860s
1 tests, 4 assertions, 0 failures, 0 errors, 0 skips
```

+ `$ rails test`を実行<br>

```:terminal
[+] Running 1/0
 ⠿ Container rails-db  Running                                                                                                               0.0s
Running via Spring preloader in process 16
Started with run options --seed 42862

  21/21: [===================================================================================================] 100% Time: 00:00:02, Time: 00:00:02

Finished in 2.90685s
21 tests, 45 assertions, 0 failures, 0 errors, 0 skips
```

# 8.2 ログイン

## リスト 8.13: ApplicationコントローラにSessionヘルパーモジュールを読み込む

+ `app/controller/application_controller.rb`を編集<br>

```rb:application_controller.rb
class ApplicationController < ActionController::Base
  include SessionsHelper
end
```

# 8.2.1 `log_in` メソッド

## リスト 8.14: `log_in` メソッド

+ `app/helpers/sessions_helper.rb`<br>

```rb:sessions_helper.rb
module SessionsHelper

  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end
end
```

## リスト 8.15: ユーザーにログインする

+ `app/controllers/sessions_controller.rb`を編集<br>

```rb:sessions_controller.rb
class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # 追加
      log_in user # helperメソッドから
      redirect_to user
      # ここまで
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end
  # エラ〜メッセージを作成する
  def destroy

  end
end
```

## リスト 8.16: セッションに含まれる現在のユーザーを検索する

+ `app/helpers/sessions_helper.rb`を編集<br>

```rb:sessions_helper.rb
module SessionsHelper

  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  # 現在ログイン中のユーザーを返す(いる場合)
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end
end
```

# 8.2.3 レイアウトリンクを変更する

## リスト 8.18: `logged_in?`ヘルパーメソッド

+ `app/helpers/sessions_helper.rb`を編集<br>

```rb:sessions_helper.rb
module SessionsHelper

  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  # 現在ログイン中のユーザーを返す (いる場合)
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end

  # ユーザーがログインしていればtrue, その他ならfalseを返す
  def logged_in? # 論理値を返すメソッド
    !current_user.nil?
  end
end
```

## リスト 8.19: ログイン中のユーザー用のレイアウトのリンクを変更する

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
            <li><%= link_to "Settings", '#' %></li>
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

+ `$ yarn add jquery@3.4.1 bootstrap@3.4.1`を実行<br>

## リスト 8.20: WebpackにjQueryの設定を追加する

+ `config/webpack/environment.js`を編集<br>

```js:environment.js
const { environment } = require('@rails/webpacker')

// 追加
const webpack = require('webpack')
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery/src/jquery',
    jQuery: 'jquery/src/jquery'
  })
)
// ここまで

module.exports = environment
```

## リスト 8.2.1: 必要なJavaScriptファイルをrequireまたはimportする

+ `app/javascript/packs/application.js`を編集<br>

```js:application.js
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
// 追加
require("jquery")
import "bootstrap"
// ここまで

Rails.start()
Turbolinks.start()
ActiveStorage.start()
```

# 8.2.4 レイアウトの変更をテストする

## リスト 8.22: fixture向けのdigestメソッドを追加する

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

  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                   BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
end
```

## リスト 8.23: ユーザーログインのテストで使うfixture

+ `test/fixtures/users.yml`を編集<br>

```yml:users.yml
michael:
  name: michael Example
  email: michael@example.com
  password_digest: <%=  User.digest('password') %>
```

## リスト 8.24: 有効な情報を使ってユーザーログインをテストする(GREEN)

+ `test/integration/users_login_test.rb`を編集<br>

```rb:users_login_test.rb
require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest

  # 追加
  def setup
    @user = users(:michael)
  end

  test "login with invalid information" do
    get login_path
    post login_path, params: { session: { email: @user.email, password: "password" } }
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end
end
```

+ `$ rails test test/integration/users_login_test.rb`を実行<br>

```:terminal
[+] Running 1/0
 ⠿ Container rails-db  Running                                                                                                               0.0s
Running via Spring preloader in process 17
Started with run options --seed 23669

  1/1: [=====================================================================================================] 100% Time: 00:00:01, Time: 00:00:01

Finished in 1.11428s
1 tests, 6 assertions, 0 failures, 0 errors, 0 skips
```

## リスト 8.28: "ぼっち演算子" `&.` でログインコードをシンプルな形に書き直す

+ `app/controllers/sessions_controller.rb`を編集<br>

```rb:sessions_controller.rb
class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password]) # 編集
      log_in user # helperメソッドから
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end
  # エラ〜メッセージを作成する
  def destroy

  end
end
```

## リスト 8.29: ユーザー登録中にログインする

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
      log_in @user # 追加
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
```

## リスト 8.30: テスト中のログインステータスを論理値で返すメソッド

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

  # 追加
  def is_logged_in?
    !session[:user_id].nil?
  end
end
```

## リスト 8.31: ユーザー登録後のログインのテスト(GREEN)

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
    assert_template 'users/show'
    assert is_logged_in? # 追加
  end
end
```

+ `$ rails test`を実行<br>

```:terminal
ompose run --rm web rails t
[+] Running 1/0
 ⠿ Container rails-db  Ru...                      0.0s
Running via Spring preloader in process 18
Started with run options --seed 2946

  21/21: [========] 100% Time: 00:00:03, Time: 00:00:03

Finished in 3.47129s
21 tests, 48 assertions, 0 failures, 0 errors, 0 skips
```

# 8.3 ログアウト

## リスト 8.33: `log_out`メソッド

+ `app/helpers/sessions_helper.rb`を編集<br>

```rb:sessions_helper.rb
module SessionsHelper

  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end

  def logged_in?
    !current_user.nil?
  end

  # 追加
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
end
```

## リスト 8.34: セッションを破棄する (ユーザーのログアウト)

+ `app/controllers/sessions_controller.rb`を編集<br>

```rb:sessions_controller.rb
class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      log_in user # helperメソッドから
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    # 追加
    log_out
    redirect_to root_url
    # ここまで
  end
end
```

## リスト 8.35: ユーザーログアウトのテスト (無効なログインテストも一箇所改良) GREEN

+ `test/integrations/users_login_test.rb`を編集<br>

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
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end
end
```

+ `$ rails test`を実行<br>

```:terminal
[+] Running 1/0
 ⠿ Container rails-db  Ru...                      0.0s
Running via Spring preloader in process 18
Started with run options --seed 37313

  22/22: [===================================================================================================] 100% Time: 00:00:03, Time: 00:00:03

Finished in 3.21705s
22 tests, 58 assertions, 0 failures, 0 errors, 0 skips
```
