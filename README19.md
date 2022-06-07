# 14.2 [follow] のWebインターフェイス

# 14.2.1 フォローのサンプルデータ

## リスト 14.14: サンプルデータにfollowing/followerの関係性を追加する

+ `db/seeds.rb`を編集<br>

```rb:seeds.rb
# メインのサンプルユーザーを1人作成する
User.create!(name:  "Takaki Nakamura",
             email: "takaki55730317@gmail.com",
             password:               "password123",
             password_confirmation:  "password123",
             admin: true,
             activated: true,
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
               activated: true,
               activated_at: Time.zone.now)
end

# ユーザーの一部を対象にマイクロポストを生成する
users = User.order(:created_at).take(6)
50.times do
  content = Faker::Lorem.sentence(word_count: 5)
  users.each { |user| user.microposts.create!(content: content) }
end

# 追加
# リレーションシップを作成する
users = User.all
user = users.first
following = users[2..50]
followers = users[3..40]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }
```

+ `$ rails db:migrate:reset`を実行<br>

+ `$ rails db:seed`を実行<br>

# 14.2.2 統計と [follow] フォーム

## リスト 14.15: Usersコントローラに`following`アクションと`followers`アクションを追加する

+ `config/routes.rb`を編集<br>

```rb:routes.rb
Rails.application.routes.draw do
  root   'static_pages#home'
  get    '/help',    to: 'static_pages#help'
  get    '/about',   to: 'static_pages#about'
  get    '/contact', to: 'static_pages#contact'
  get    '/signup',  to: 'users#new'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :microposts,          only: [:create, :destroy]
end
```

|HTTPリクエスト|URL|アクション|名前付きルート|
|:---:|:---:|:---:|:---:|
|GET|/users/1/following|following|following_user_path(1)|
|GET|/users/1/followers|followers|followers_user_path(1)|

## リスト 14.16: フォロワーの統計情報を表示するパーシャル

+ `$ touch app/views/shared/_stats.html.erb`を実行<br>

+ `app/views/shared/_stats.html.erb`を編集<br>

```html:_stats.html.erb
<% @user ||= current_user %>
<div class="stats">
  <a href="<%= following_user_path(@user) %>">
    <strong id="following" class="stat">
      <%= @user.following.count %>
    </strong>
    following
  </a>
  <a href="<%= followers_user_path(@user) %>">
    <strong id="followers" class="stat">
      <%= @user.followers.count %>
    </strong>
    followers
  </a>
</div>
```

## リスト 14.17: Homeページにフォロワーの統計情報を追加する

+ `app/views/static_pages/home.html.erb`を編集<br>

```html:home.html.erb
<% if logged_in? %>
<div class="row">
  <aside class="col-md-4">
    <section class="user_info">
      <%= render 'shared/user_info' %>
    </section>
    <!-- 追加 -->
    <section class="stats">
      <%= render 'shared/stats' %>
    </section>
    <!-- ここまで -->
    <section class="micropost_form">
      <%= render 'shared/micropost_form' %>
    </section>
  </aside>
  <div class="col-md-8">
    <h3>Micropost Feed</h3>
    <%= render 'shared/feed' %>
  </div>
</div>
<% else %>
<div class="center jumbotron">
  <h1>Welcome to the Sample App</h1>

  <h2>
    This is the home page for the
    <a href="https://railstutorial.jp/">Ruby on Rails Tutorial</a>
    Sample application.
  </h2>

  <%= link_to "Sign up now!", signup_path, class: "btn btn-lg btn-primary" %>
</div>

<%= link_to image_tag("rails.svg", alt: "Rails logo", width: "200px"), "https://rubyonrails.org/" %>
<% end %>
```

# リスト 14.18: Homeページのサイドバー用のSCSS

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

// 追加
.stats {
  overflow: auto;
  margin-top: 0;
  padding: 0;
  a {
    float: left;
    padding: 0 10px;
    border-left: 1px solid $gray-lighter;
    color: gray;
    &:first-child {
      padding-left: 0;
      border: 0;
    }
    &:hover {
      text-decoration: none;
      color: blue;
    }
  }
  strong {
    display: block;
  }
}

.user_avatars {
  overflow: auto;
  margin-top: 10px;
  .gravatar {
    margin: 1px 1px;
  }
  a {
    padding: 0;
  }
}

.users.follow {
  padding: 0;
}
// ここまで

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

/* microposts */

.microposts {
  list-style: none;
  padding: 0;
  li {
    padding: 10px 0;
    border-top: 1px solid #e8e8e8;
  }
  .user {
    margin-top: 5em;
    padding-top: 0;
  }
  .content {
    display: block;
    margin-left: 60px;
    img {
      display: block;
      padding: 5px 0;
    }
  }
  .timestamp {
    color: $gray-light;
    display: block;
    margin-left: 60px;
  }
  .gravatar {
    float: left;
    height: 50px;
    margin-right: 10px;
    margin-top: 5px;
  }
}

aside {
  textarea {
    height: 100px;
    margin-bottom: 5px;
  }
}

span.image {
  margin-top: 10px;
  input {
    border: 0;
  }
}
```

## リスト 14.19: フォロー/フォロー解除フォームのパーシャル

+ `$ touch app/views/users/_follow_form.html.erb`を実行<br>

+ `app/views/users/_follow_form.html.erb`を編集<br>

```html:_follow_form.html.erb
<% unless current_user?(@user) %>
<div id="follow_form">
  <% if current_user.following?(@user) %>
  <%= render 'unfollow' %>
  <% else %>
  <%= render 'follow' %>
  <% end %>
</div>
<% end %>
```

## リスト 14.20: Relationshipリソース用のルーティングを追加する

+ `config/routes.rb`を編集<br>

```rb:routes.rb
Rails.application.routes.draw do
  root   'static_pages#home'
  get    '/help',    to: 'static_pages#help'
  get    '/about',   to: 'static_pages#about'
  get    '/contact', to: 'static_pages#contact'
  get    '/signup',  to: 'users#new'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :microposts,          only: [:create, :destroy]
  resources :relationships,       only: [:create, :destroy] # 追加
end
```

## リスト 14.21: ユーザーをフォローするフォーム

+ `$ touch app/views/users/_follow.html.erb`を実行<br>

+ `app/views/users/_follow.html.erb`を編集<br>

```html:_follow.html.erb
<%= form_with(model: current_user.active_relationships.build, local: true) do |f| %>
<div><%= hidden_field_tag :followed_id, @user.id %></div>
<%= f.submit "Follow", class: "btn btn-primary" %>
<% end %>
```

## リスト 14.22: ユーザーをフォロー解除するフォーム

+ `$ touch app/views/users/_unfollow.html.erb`を実行<br>

+ `app/views/users/_unfollow.html.erb`を編集<br>

```html:_unfollow.html.erb
<%= form_with(model: current_user.active_relationships.find_by(followed_id: @user.id),
            html: { method: :delete }, local: true) do |f| %>
<%= f.submit "Unfollow", class: "btn btn-default" %>
<% end %>
```

## リスト 14.23: プロフィールページにフォロー用フォームとフォロワーの統計情報を追加する

+ `app/views/users/show.html.erb`を編集<br>

```html:show.html.erb
<% provide(:title, @user.name) %>
<div class="row">
  <aside class="col-md-4">
    <section class="user_info">
      <h1>
        <%= gravatar_for @user %>
        <%= @user.name %>
      </h1>
    </section>
    <!-- 追加 -->
    <section class="stats">
      <%= render 'shared/stats' %>
    </section>
    <!-- ここまで -->
  </aside>
  <div class="col-md-8">
    <!-- 追加 -->
    <%= render 'follow_form' if logged_in? %>
    <% if @user.microposts.any? %>
    <h3>Microposts (<%= @user.microposts.count %>)</h3>
    <ol class="microposts">
      <%= render @microposts %>
    </ol>
    <%= will_paginate @microposts %>
    <% end %>
  </div>
</div>
```

# 14.2.3 [Following] と [Followers] ページ

## リスト 14.24: フォロー/フォロワーページの認可をテストする (RED)

+ `test/controllers/users_controller_test.rb`を編集<br>

```rb:users_controller_test.rb
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user       = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
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

  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end

  # 追加
  test "should redirect following when not logged in" do
    get following_user_path(@user)
    assert_redirected_to login_url
  end

  test "should redirect followers when not logged in" do
    get followers_user_path(@user)
    assert_redirected_to login_url
  end
  # ここまで
end
```

## リスト 14.25: `following`アクションと`followers`アクション (RED)

+ `app/controllwers/users_controller.rb`を編集<br>

```rb:users_controller.rb
class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,
                                        :following, :followers] # 追加
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
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

  # 追加
  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end
  # ここまで

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

  # beforeフィルター

  # 正しいユーザーかどうかを確認
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

## リスト 14.26: フォローしているユーザーとフォロワーの両方を表示する `show_follow` ビュー (GREEN)

+ `$ touch app/views/users/show_follow.html.rb`を実行<br>

+ `app/views/users/show_follow.html.erb`を編集<br>

```html:show_follow.html.erb
<% provide(:title, @title) %>
<div class="row">
  <aside class="col-md-4">
    <section class="user_info">
      <%= gravatar_for @user %>
      <h1><%= @user.name %></h1>
      <span><%= link_to "view my profile", @user %></span>
      <span><b>Microposts:</b> <%= @user.microposts.count %></span>
    </section>
    <section class="stats">
      <%= render 'shared/stats' %>
      <% if @users.any? %>
      <div class="user_avatars">
        <% @users.each do |user| %>
        <%= link_to gravatar_for(user, size: 30), user %>
        <% end %>
      </div>
      <% end %>
    </section>
  </aside>
  <div class="col-md-8">
    <h3><%= @title %></h3>
    <% if @users.any? %>
    <ul class="users follow">
      <%= render @users %>
    </ul>
    <%= will_paginate %>
    <% end %>
  </div>
</div>
```

## リスト 14.27: GREEN

+ `$ rails test`を実行(GREEN)<br>

+ `$ rails g integration_test following`を実行<br>

## リスト 14.28: following/followerをテストするためのリレーションシップ用fixture

+ `test/fixtures/relationships.yml`を編集<br>

```yml:relationships.yml
one:
  follower: michael
  followed: lana

tow:
  follower: michael
  followed: malory

three:
  follower: lana
  followed: michael

four:
  follower: archer
  followed: michael
```

## リスト 14.29: following/followerページのテスト (GREEN)

+ `test/integration/following_test.rb`を編集<br>

```rb:following_test.rb
require "test_helper"

class FollowingTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    log_in_as(@user)
  end

  test "following page" do
    get following_user_path(@user)
    assert_not @user.following.empty?
    assert_match @user.following.count.to_s, response.body
    @user.following.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "followers page" do
    get followers_user_path(@user)
    assert_not @user.followers.empty?
    assert_match @user.followers.count.to_s, response.body
    @user.followers.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end
end
```

## リスト 14.30: GREEN

+ `$ rails test`を実行(GREEN)<br>
