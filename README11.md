# 10.3.4 ユーザー一覧のテスト

## リスト 10.47: fixtureにさらに30人のユーザーを追加する

+ `test/fixtures/users.yml`を編集<br>

```yml:users.yml
michael:
  name: michael Example
  email: michael@example.com
  password_digest: <%=  User.digest('password') %>

archer:
  name: Sterling Archer
  email: duchess@example.gov
  password_digest: <%= User.digest('password') %>

lana:
  name: Lana Kane
  email: hands@example.gov
  password_digest: <%= User.digest('password') %>

malory:
  name: Malory Archer
  email: boss@example.gov
  password_digest: <%= User.digest('password') %>

<% 30.times do |n| %>
user_<%= n %>:
  name:  <%= "User #{n}" %>
  email: <%= "user-#{n}@example.com" %>
  password_digest: <%= User.digest('password') %>
<% end %>
```

## リスト 10.48: ページネーションを含めたUsersIndexのテスト(GREEN)

+ `$ rails g integration_test users_index`を実行<br>

+ `test/integration/users_index_test.rb`を編集<br>

```rb:users_index_test.rb
require "test_helper"

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "index including pagination" do
    log_in_as(@user)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    User.paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end
end
```

+ `$ rails test`を実行(GREEN)<br>

# 10.3.5 パーシャルのリファクタリング

## リスト 10.50: indexニューに対する最初のリファクタリング(RED)

+ `app/views/users/index.html.erb`を編集<br>

```html:index.html.erb
<% provide(:title, 'All users') %>
<h1>All users</h1>

<%= will_paginate %>

<ul class="users">
  <% @users.each do |user| %>
  <li>
    <!-- 編集 -->
    <%= render user %>
  </li>
  <% end %>
</ul>

<%= will_paginate %>
```

+ `$ touch app/views/users/_user.html.erb`を実行<br>

+ `app/views/users/_user.html.erb`を編集<br>

```html:_user.html.erb
<li>
  <%= gravatar_for user, size: 50 %>
  <%= link_to user.name, user %>
</li>
```

## リスト 10.52: indexページの完全なリファクタリング(GREEN)

+ `app/views/users/index.html.erb`を編集<br>

```html:index.html.erb
<% provide(:title, 'All users') %>
<h1>All users</h1>

<%= will_paginate %>

<ul class="users">
  <%= render @users %>
</ul>

<%= will_paginate %>
```

+ `$ rails test`を実行(GREEN)<br>

# 10.4 ユーザーを削除する

## 10.4.1 管理ユーザー

+ `$ rails g migration add_admin_to_users admin:boolean`を実行<br>

## リスト 10.54: boolean型の`admin`属性をUserに追加するマイグレーション

+ `db/migrate/add_admin_to_users.rb`を編集<br>

```rb:add_admin_to_users.rb
class AddAdminToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :admin, :boolean, default: false # 編集
  end
end
```

+ `$ rails db:migrate`を実行<br>

```:terminal
root@588b3b9a9012:/app# rails console --sandbox
Running via Spring preloader in process 61
Loading development environment in sandbox (Rails 6.1.6)
Any modifications you make will be rolled back on exit
irb(main):001:0> user = User.first
  TRANSACTION (0.4ms)  BEGIN
  User Load (4.3ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" ASC LIMIT $1  [["LIMIT", 1]]
=> #<User id: 1, name: "Example User", email: "example@railstutorial.org", created_at: "2022-05-26 11:08:28.524521000 +0000", updated_at: "2022-05-26 11:08:28.524521000 +0000", password_digest: [FILTERED], remember_digest: nil, admin: false>
irb(main):002:0> user.admin?
=> false
irb(main):003:0> user.toggle!(:admin)
  TRANSACTION (0.9ms)  SAVEPOINT active_record_1
  User Update (2.3ms)  UPDATE "users" SET "updated_at" = $1, "admin" = $2 WHERE "users"."id" = $3  [["updated_at", "2022-05-26 12:55:53.437018"], ["admin", true], ["id", 1]]
  TRANSACTION (1.9ms)  RELEASE SAVEPOINT active_record_1
=> true
irb(main):004:0> user.admin?
=> true
```

## リスト 10.55: サンプルデータ生成タスクに管理者を1人追加する

+ `db/seeds.rb`を編集<br>

```rb:seeds.rb
# メインのサンプルユーザーを1人作成する
User.create!(name:  "Takaki Nakamura",
             email: "takaki55730317@gmail.com",
             password:               "password123",
             password_confirmation:  "password123",
            admin: true)

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

## リスト 10.57: ユーザー削除用リンクの実装（管理者にのみ表示される)

+ `app/views/users/_user.html.erb`を編集<br>

```html:_user.html.erb
<li>
  <%= gravatar_for user, size: 50 %>
  <%= link_to user.name, user %>
  <% if current_user.admin? && !current_user?(user) %>
  | <%= link_to "delete", user, method: :delete, data: { confirm: "Your sure?" } %>
  <% end %>
</li>
```

## リスト 10.58: 実際に動作する `destroy`アクションを追加する

+ `app/controllers/users_controller.rb`を編集<br>

```rb:users_controller.rb
class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy] # 編集
  before_action :correct_user,   only: [:edit, :update]

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

  # 追加
  def destroy
    user.find(params[:id]).destroy
    flas[:success] = "User deleted"
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
end
```

## リスト 10.59: beforeフィルターで`destroy`アクションを管理者だけに限定する

+ `app/controllers/users_controller.rb`を編集<br>

```rb:users_controller.rb
class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy # 追加

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

  # 追加
  # 管理者かどうか確認
  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end
```

# 10.4.3 ユーザー削除のテスト

## リスト 10.60: fixture内の最初のユーザーを管理者にする

+ `test/fixtures/users.yml`を編集<br>

```yml:users.yml
michael:
  name: michael Example
  email: michael@example.com
  password_digest: <%=  User.digest('password') %>
  admin: true # 追加

archer:
  name: Sterling Archer
  email: duchess@example.gov
  password_digest: <%= User.digest('password') %>

lana:
  name: Lana Kane
  email: hands@example.gov
  password_digest: <%= User.digest('password') %>

malory:
  name: Malory Archer
  email: boss@example.gov
  password_digest: <%= User.digest('password') %>

<% 30.times do |n| %>
user_<%= n %>:
  name:  <%= "User #{n}" %>
  email: <%= "user-#{n}@example.com" %>
  password_digest: <%= User.digest('password') %>
<% end %>
```

## リスト 10.61: 管理者権限の制御をアクションレベルでテストする(GREEN)

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

  # 追加
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
  # ここまで
end
```

## リスト 10.62: 削除リンクとユーザー削除に対する統合テスト(GREEN)

+ `test/integration/users_index_test.rb`を編集<br>

```rb:users_index_test.rb
require "test_helper"

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:michael) # 編集
    @non_admin = users(:archer)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
end
```

## リスト 10.63: GREEN

+ `$ rails test`を実行(GREEN)
