# 10.2.3 フレンドリーフォワーディング

## リスト 10.29: フレンドリーフォワーディングのテスト(RED)

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

  # 編集
  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user) # test_helperから
    assert_redirected_to edit_user_url(@user)
    get edit_user_path(@user)
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

## リスト 10.30: フレンドリーフォワーディングの実装(RED)

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

  # 追加
  # 記憶したURL（もしくはデフォルト値）にリダイレクト
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # アクセスしようとしたURLを覚えておく
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
  # ここまで
end
```

## リスト 10.31: ログインユーザー用beforeフィルターに`store_location`を追加する(RED)

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
      store_location # 追加
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end
end
```

## リスト 10.32: フレンドリーフォワーディングを備えた`create`アクション(GREEN)

+ `app/controllers/sessions_controller.rb`を編集<br>

```rb:sessions_controller.rb
class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      log_in user # helperメソッドから
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_back_or user # 編集
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

+ `$ rails test`を実行(GREEN)<br>

# 10.3 すべてのユーザーを表示する

## 10.3.1 ユーザーの一覧ページ

## リスト 10.34: `index`アクションのリダイレクトをテストする(RED)

+ `test/controllers/users_controller_test.rb`を編集<br>

```rb:users_controller_test.rb
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user       = users(:michael)
    @other_user = users(:archer)
  end

  # 追加
  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end
  # ここまで

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

  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end
end
```

## リスト 10.35: `index`アクションにはログインを要求する(GREEN)

+ `app/controllers/users_controller.rb`を編集<br>

```rb:users_controller.rb
class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update] # 編集
  before_action :correct_user,   only: [:edit, :update]

  # 追加
  def index

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
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end
end
```

## リスト 10.36: ユーザーの`index`アクション

+ `app/controllers/users_controller.rb`を編集<br>

```rb:users_controller.rb
class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update]
  before_action :correct_user,   only: [:edit, :update]

  def index
    @users = User.all # 追加
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
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end
end
```

## リスト 10.37: ユーザーのindexビュー

+ `$ touch app/views/users/index.html.erb`を実行<br>

+ `app/views/users/index.html.erb`を編集<br>

```html:index.html.erb
<% provide(:title, 'All users') %>
<h1>All users</h1>

<ul class="users">
  <% @users.each do |user| %>
  <li>
    <%= gravatar_for user, size: 50 %>
    <%= link_to user.name, user %>
  </li>
  <% end %>
</ul>
```

## リスト 10.38: `gravatar_for`ヘルパーにオプション引数を追加する

+ `app/helpers/users_helpers.rb`を編集<br>

```rb:users_helper.rb
module UsersHelper

  # 渡されたユーザーのGravatar画像を返す
  def gravatar_for(user, options = { size: 80 }) # 編集
    size         = options[:size] # 編集
    gravatar_id  = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end
```

## リスト 10.39: ユーザーのindexページ用のCSS

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

// 追加
/* Users index */

.users {
  list-style: none;
  margin: 0;
  li {
    overflow: auto;
    padding: 10px 0;
    border-bottom: 1px solid $gray-lighter;
  }
}
// ここまで
```

## リスト 10.40: ユーザー一覧ページへのリンクを更新する

+ `app/views/layouts/_header.html.erb`を編集<br>

```erb:_header.html.erb
<header class="navbar navbar-fixed-top navbar-inverse">
  <div class="container">
    <%= link_to "sample app", root_path, id: "logo" %>
    <nav>
      <ul class="nav navbar-nav navbar-right">
        <li><%= link_to "Home",   root_path %></li>
        <li><%= link_to "Help",   help_path %></li>
        <% if logged_in? %>
        <li><%= link_to "Users", users_path %></li> # 編集
        <li class="dropdown">
          <a href="#" class="dropdown-toggle" data-toggle="dropdown">
            Account <b class="caret"></b>
          </a>
          <ul class="dropdown-menu">
            <li><%= link_to "Profile", current_user %></li>
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

+ `$ rails test`を実行(GREEN)<br>

# 10.3.2 サンプルのユーザー

## リスト 10.42: `Gemfile`にFaker gemを追加する

+ `Gemfile`を編集<br>

```:Gemfile
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.6'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
gem 'bootstrap-sass', '3.4.1'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
gem 'bcrypt', '~> 3.1.7'
gem 'faker', '2.20.0' # 追加

# コンソールの出力結果を見やすく表示する
gem 'hirb', '~> 0.7.3'

# Hirbの文字列補正を行う
gem 'hirb-unicode-steakknife', '~> 0.0.9'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0', require: false
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  # テスト結果色付け Doc: https://github.com/kern/minitest-reporters
  gem 'minitest-reporters', '~> 1.1', '>= 1.1.11'
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver', '>= 4.0.0.rc1'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
  gem 'rails-controller-testing', '1.0.4'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
```

+ `$ docker compose build`を実行<br>

## リスト 10.43: データベース上にサンプルユーザーに生成するRailsタスク

+ `db/seeds.rb`を編集<br>

```rb:seeds.rb
# メインのサンプルユーザーを1人作成する
User.create!(name:  "Example User",
             email: "example@railstutorial.org",
             password:               "foobar",
             password_confirmation:  "foobar")

# 追加のユーザーをまとめて生成する
99.times do |n|
  name    = Faker::Name.name
  email   = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password)
end
```

+ `$ rails db:migrate:reset`を実行<br>

+ `$ rails db:seed`を実行<br>

# 10.3.3 ページネーション

## リスト 10.44: `Gemfile`に `will_paginate`を追加する

+ `Gemfile`を編集<br>

```:Gemfile
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.6'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
gem 'bootstrap-sass', '3.4.1'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
gem 'bcrypt', '~> 3.1.7'
gem 'faker', '2.20.0'
gem 'will_paginate', '3.3.1' # 追加
gem 'bootstrap-will_paginate', '1.0.0' # 追加

# コンソールの出力結果を見やすく表示する
gem 'hirb', '~> 0.7.3'

# Hirbの文字列補正を行う
gem 'hirb-unicode-steakknife', '~> 0.0.9'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0', require: false
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  # テスト結果色付け Doc: https://github.com/kern/minitest-reporters
  gem 'minitest-reporters', '~> 1.1', '>= 1.1.11'
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver', '>= 4.0.0.rc1'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
  gem 'rails-controller-testing', '1.0.4'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
```

+ `$ docker compose build`を実行<br>

## リスト 10.45: indexページでpaginationを使う

+ `app/views/users/index.html.erb`を編集<br>

```html:index.html.erb
<% provide(:title, 'All users') %>
<h1>All users</h1>

<!-- 追加 -->
<%= will_paginate %>

<ul class="users">
  <% @users.each do |user| %>
  <li>
    <%= gravatar_for user, size: 50 %>
    <%= link_to user.name, user %>
  </li>
  <% end %>
</ul>

<!-- 追加 -->
<%= will_paginate %>
```

+ `$ rails console`を実行<br>

```:terminal
irb(main):001:0> User.paginate(page: 1)
  User Load (1.0ms)  SELECT "users".* FROM "users" /* loading for inspect */ LIMIT $1 OFFSET $2  [["LIMIT", 11], ["OFFSET", 0]]
   (1.1ms)  SELECT COUNT(*) FROM "users" /* loading for inspect */
=> #<ActiveRecord::Relation [#<User id: 1, name: "Example User", email: "example@railstutorial.org", created_at: "2022-05-26 11:08:28.524521000 +0000", updated_at: "2022-05-26 11:08:28.524521000 +0000", password_digest: [FILTERED], remember_digest: nil>, #<User id: 2, name: "Prof. Brandon White", email: "example-1@railstutorial.org", created_at: "2022-05-26 11:08:38.383289000 +0000", updated_at: "2022-05-26 11:08:38.383289000 +0000", password_digest: [FILTERED], remember_digest: nil>, #<User id: 3, name: "Monty Crona", email: "example-2@railstutorial.org", created_at: "2022-05-26 11:08:38.713082000 +0000", updated_at: "2022-05-26 11:08:38.713082000 +0000", password_digest: [FILTERED], remember_digest: nil>, #<User id: 4, name: "Clayton West", email: "example-3@railstutorial.org", created_at: "2022-05-26 11:08:39.044809000 +0000", updated_at: "2022-05-26 11:08:39.044809000 +0000", password_digest: [FILTERED], remember_digest: nil>, #<User id: 5, name: "The Hon. Charlette Hayes", email: "example-4@railstutorial.org", created_at: "2022-05-26 11:08:39.378237000 +0000", updated_at: "2022-05-26 11:08:39.378237000 +0000", password_digest: [FILTERED], remember_digest: nil>, #<User id: 6, name: "Lacy Krajcik", email: "example-5@railstutorial.org", created_at: "2022-05-26 11:08:39.708630000 +0000", updated_at: "2022-05-26 11:08:39.708630000 +0000", password_digest: [FILTERED], remember_digest: nil>, #<User id: 7, name: "Kory Cronin", email: "example-6@railstutorial.org", created_at: "2022-05-26 11:08:40.032622000 +0000", updated_at: "2022-05-26 11:08:40.032622000 +0000", password_digest: [FILTERED], remember_digest: nil>, #<User id: 8, name: "Harriette Bins", email: "example-7@railstutorial.org", created_at: "2022-05-26 11:08:40.358303000 +0000", updated_at: "2022-05-26 11:08:40.358303000 +0000", password_digest: [FILTERED], remember_digest: nil>, #<User id: 9, name: "Grady Welch", email: "example-8@railstutorial.org", created_at: "2022-05-26 11:08:40.691137000 +0000", updated_at: "2022-05-26 11:08:40.691137000 +0000", password_digest: [FILTERED], remember_digest: nil>, #<User id: 10, name: "Wilmer Johnston", email: "example-9@railstutorial.org", created_at: "2022-05-26 11:08:41.024272000 +0000", updated_at: "2022-05-26 11:08:41.024272000 +0000", password_digest: [FILTERED], remember_digest: nil>, ...]>

irb(main):004:0> User.paginate(page: 1).length
  User Load (0.6ms)  SELECT "users".* FROM "users" LIMIT $1 OFFSET $2  [["LIMIT", 30], ["OFFSET", 0]]
=> 30
```

## リスト 10.46: `index`アクションでUsersをページネートする

+ `app/controllers/users_controller.rb`を編集<br>

```rb:users_controller.rb
class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update]
  before_action :correct_user,   only: [:edit, :update]

  def index
    @users = User.paginate(page: params[:page]) # 編集
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
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end
end
```
