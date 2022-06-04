# 13.3 マイクロポストを操作する

## リスト 13.30: マイクロポストリソースのルーティング

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
  resources :microposts,          only: [:create, :destroy] # 追加
end
```

# 13.3.1 マイクロポストのアクセス制御

## リスト 13.31: Micropostsコントローラの認可テスト (RED)

+ `test/controllers/microposts_controller_test.rb`を編集<br>

```rb:microposts_controller_test.rb
require "test_helper"

class MicropostsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @micropost = microposts(:orange)
  end

  test "should redirect create when not logged in" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "Lorem ipsum" } }
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost)
    end
    assert_redirected_to login_url
  end
end
```

## リスト 13.32: `logged_in_user`メソッドをApplicationコントローラに移す (RED)

+ `app/controller/application_controller.rb`を編集<br>

```rb:application_controller.rb
class ApplicationController < ActionController::Base
  include SessionsHelper

  private

  # 追加
  # ユーザーのログインを確認する
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end
end
```

## リスト 13.33: Usersコントローラ内の`logged_in_user`フィルターを削除する(RED)

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

  # 追加
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

## リスト 13.34: Micropostsコントローラの各アクションに認可を追加する(GREEN)

+ `app/controllers/microposts_controller.rb`を編集<br>

```rb:microposts_controller.rb
class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]

  def create
  end

  def destroy
  end
end
```

## リスト 13.35: GREEN

+ `$ rails test`を実行(GREEN)<br>

# 13.3.2 マイクロポストを作成する

## リスト 13.36: Micropostsコントローラの`create`アクション

+ `app/controllers/microposts_controller.rb`を編集<br>

```rb:microposts_controller.rb
class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      render 'static_pages/home'
    end
  end

  def destroy
  end

  private

  def micropost_params
    params.require(:micropost).permit(:content)
  end
end
```

## リスト 13.37: Homeページ (/) にマイクロポストの投稿フォームを追加する

+ `app/views/static_pages/home.html.erb`を編集<br>

```html:home.html.erb
<!-- 追加 -->
<% if logged_in? %>
<div class="row">
  <aside class="col-md-4">
    <section class="user_info">
      <%= render 'shared/user_info' %>
    </section>
    <section class="micropost_form">
      <%= render 'shared/micropost_form' %>
    </section>
  </aside>
</div>
<% else %>
<!-- ここまで -->
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
<!-- 追加 -->
<%end%>
```

## リスト 13.38: サイドバーで表示するユーザー情報のパーシャル

+ `$ touch app/views/shared/_user_info.html.erb`を実行<br>

+ `app/views/shared/_user_info.html.erb`を編集<br>

```html:_user_info_html.erb
<%= link_to gravatar_for(current_user, size: 50), current_user %>
<h1><%= current_user.name %></h1>
<span><%= link_to "view myprofile", current_user %></span>
<span><%= pluralize(current_user.microposts.count, "micropost") %></span>
```

## リスト 13.39: マイクロポスト投稿フォームのパーシャル

+ `$ touch app/views/shared/_micropost_form.html.erb`を実行<br>

+ `app/views/shared/_micropost_form.html.erb`を編集<br>

```html:_micropost_form.html.erb
<%= form_with(model: @micropost, local: true) do |f| %>
<%= render 'shared/error_messages', object: f.object %>
<div class="field">
  <%= f.text_area :content, placeholder: "Compose new micropost..." %>
</div>
<%= f.submit "Post", class: "btn btn-primary" %>
<% end %>
```

## リスト 13.40: `home`アクションにマイクロポストのインスタンス件数を追加する

+ `app/controllers/static_pages_controller.rb`を編集<br>

```rb:static_pages_controller.rb
class StaticPagesController < ApplicationController
  def home
    @micropost = current_user.microposts.build if logged_in?
  end

  def help
  end

  def about
  end

  def contact
  end
end
```

## リスト 13.41: Userオブジェクト以外でも動作するようにerror_messagesパーシャルを更新する (RED)

+ `app/views/shared/_error_messages.html.erb`を編集<br>

```html:_error_messages.html.erb
<!-- 編集 -->
<% if object.errors.any? %>
<div id="error_explanation">
  <div class="alert alert-danger">
    The form contains <%= pluralize(object.errors.count, "error") %>.
  </div>
  <ul>
    <!-- 編集 -->
    <% object.errors.full_messages.each do |msg| %>
    <li><%= msg %></li>
    <% end %>
  </ul>
</div>
<% end %>
```

## リスト 13.42: RED

+ `$ rails test`を実行 (RED)<br>

## リスト 13.43: ユーザー登録時のエラー表示を更新する (RED)

+ `app/views/users/new.html.erb`を編集<br>

```html:new.html.erb
<% provide(:title, 'Sign up') %>
<h1>Sign up</h1>

<div class="row">
  <div class="col-md-6 col-md-offset-3">
    <%= form_with(model: @user, local: true) do |f| %>
    <!-- 編集 -->
    <%= render 'shared/error_messages', object: f.object %>

    <%= f.label :name %>
    <%= f.text_field :name, class: 'form-control' %>

    <%= f.label :email %>
    <%= f.email_field :email, class: 'form-control' %>

    <%= f.label :password %>
    <%= f.password_field :password, class: 'form-control' %>

    <%= f.label :password_confirmation, "Confirmation" %>
    <%= f.password_field :password_confirmation, class: 'form-control' %>

    <%= f.submit "Create my account", class: "btn btn-primary" %>
    <% end %>
  </div>
</div>
```

## リスト 13.44: ユーザー編集時のエラー表示を更新する (RED)

+ `app/views/users/edit.html.erb`を編集<br>

```html:edit.html.erb
<% provide(:title, "Edit user") %>
<h1>Update your profile</h1>

<div class="row">
  <div class="col-md-6 col-md-offset-3">
    <%= form_with(model: @user, local: true) do |f| %>
      <!-- 編集 -->
      <%= render 'shared/error_messages', object: f.object %>
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

## リスト 13.45: パスワード再設定時のエラー表示を更新する (GREEN)

+ `app/views/password_resets/edit.html.erb`を編集<br>

```html:edit.html.erb
<% provide(:title, 'Reset password') %>
<h1>Reset password</h1>

<div class="row">
  <div class="col-md-6 col-md-offset-3">
    <%= form_with(model: @user, url: password_reset_path(params[:id]), local: true) do |f| %>
    <!-- 編集 -->
    <%= render 'shared/error_messages', object: f.object %>

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

+ `$ rails test`を実行 (GREEN)<br>

+ ログインして `localhost:3200`にアクセスしてみる<br>

# 13.3.3 フィードの原型

## リスト 13.46: マイクロポストのステータスフィードを実装するための準備

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
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

  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # 試作feedの定義
  # 完全な実装は次章の 「ユーザーをフォローする」を参照
  def feed
    Micropost.where("user_id = ?", id)
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

リスト 13.47: `home` アクションにフィードのインスタンス変数を追加する

+ `app/controllers/static_pages_controller.rb`を編集<br>

```rb:static_pages_controller.rb
class StaticPagesController < ApplicationController
  def home
    # 編集
    if logged_in?
      @micropost = current_user.microposts.build if logged_in?
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
    # ここまで
  end

  def help
  end

  def about
  end

  def contact
  end
end
```

## リスト 13.48: ステータスフィードのパーシャル

+ `$ touch app/views/shared/_feed.html.erb`を実行<br>

+ `app/views/shared/_feed.html.erb`を編集<br>

```html:_feed.html.erb
<% if @feed_items.any? %>
<ol class="microposts">
  <%= render @feed_items %>
</ol>
<%= will_paginate @feed_items %>
<% end %>
```

## リスト 13.49: Homeページにステータスフィードを追加する

+ `app/views/static_pages/home.html.erb`を編集<br>

```html:home.html.erb
<% if logged_in? %>
<div class="row">
  <aside class="col-md-4">
    <section class="user_info">
      <%= render 'shared/user_info' %>
    </section>
    <section class="micropost_form">
      <%= render 'shared/micropost_form' %>
    </section>
  </aside>
  <!-- 追加 -->
  <div class="col-md-8">
    <h3>Micropost Feed</h3>
    <%= render 'shared/feed' %>
  </div>
  <!-- ここまで -->
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
<%end%>
```

+ micropostが投稿できるか試してみる<br>

## リスト 13.50: `create`アクションにからの`@feed_items`インスタンス変数を追加する

+ `app/controllers/microposts_controller.rb`を編集<br>

```rb:microposts_controller.rb
class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = current_user.feed.paginate(page: params[:page]) # 追加
      render 'static_pages/home'
    end
  end

  def destroy
  end

  private

  def micropost_params
    params.require(:micropost).permit(:content)
  end
end
```

## リスト 13.51: コントローラとアクションを明示的に設定する

+ `app/views/shared/_feed.html.erb`を編集<br>

```html:_feed.html.erb
<% if @feed_items.any? %>
<ol class="microposts">
  <%= render @feed_items %>
</ol>
<!-- 編集 -->
<%= will_paginate @feed_items, params: { controller: :static_pages, action: :home } %>
<% end %>
```
