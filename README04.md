# 5.4 ユーザー登録: 最初のステップ

## 5.4.1 Usersコントローラ

## リスト 5.38: Usersコントローラの生成(new アクションを追加)

+ `$ docker compose run --rm web rails g controller Users new`を実行<br>

+ `$ docker compose run --rm web rails test`を実行<br>

```:terminal
[+] Running 1/0
 ⠿ Container rails-db  Running                                                                                                                                                                                  0.0s
Running via Spring preloader in process 17
Started with run options --seed 41154

  6/6: [========================================================================================================================================================================] 100% Time: 00:00:04, Time: 00:00:04

Finished in 5.00512s
6 tests, 15 assertions, 0 failures, 0 errors, 0 skips
```

+ `config/routes.rb`を編集<br>

```rb:routes.rb
Rails.application.routes.draw do
  root 'static_pages#home'
  get '/help',    to: 'static_pages#help'
  get '/about',   to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
  get '/signup', to: 'users#new'
end
```

+ `test/controllers/users_controller_test.rb`を編集<br>

```rb:users_controller_test.rb
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get signup_path
    assert_response :success
  end
end
```

+ `$ docker compose run --rm web rails test`を実行<br>

```:terminal
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get signup_path
    assert_response :success
  end
end
```

+ `app/views/static_pages/home.html.erb`を編集<br>

```erb:home.html.erb
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
```

+ `app/views/users/new.html.erb`を編集<br>

```erb:new.html.erb
<% provide(:title, 'Sign up') %>
<h1>Sign up</h1>
<p>This will be a signup page for new users.</p>
```

+ `test/controllers/users_controller_test.rb`を編集<br>

```rb:users_test.rb
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get signup_path
    assert_response :success
  end
end
```

+ `test/integration/site_layout_test.rb`を編集<br>

```rb:site_layout_test.rb
require "test_helper"

class SiteLayoutTest < ActionDispatch::IntegrationTest

  test "layout links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", signup_path
    get contact_path
    assert_select "title", full_title("Contact")
    get signup_path
    assert_select "title", full_title("Sign up")
  end
end
```

+ `$ docker compose run --rm web rails test`を実行<br>

```:terminal
[+] Running 1/0
 ⠿ Container rails-db  Running                                                                                                                                                                                  0.0s
Running via Spring preloader in process 16
Started with run options --seed 59768

  6/6: [========================================================================================================================================================================] 100% Time: 00:00:04, Time: 00:00:04

Finished in 4.74180s
6 tests, 17 assertions, 0 failures, 0 errors, 0 skips
```

# 第6章 ユーザーのモデルを作成

## 6.1 Userモデル

### リスト 6.1: Userモデルを生成する

+ `$ docker compose run --rm web rails g model User name:string email:string`を実行<br>

+ `$ docker compoe run --rm web rails db:migrate`を実行<br>

# 6.1.3 ユーザーオブジェクトを生成する

+ `$ docker compose run --rm web rails c --sandbox`を実行<br>

+ `irb(main):001:0> User.new`を実行<br>

```:terminal
  TRANSACTION (0.2ms)  BEGIN
=> #<User id: nil, name: nil, email: nil, created_at: nil, updated_at: nil>
```

+ `irb(main):002:0> user = User.new(name: "Takaki Nakamura", email: "takaki55730317@gmail.com")`を実行<br>

```:terminal
=> #<User id: nil, name: "Takaki Nakamura", email: "takaki55730317@gmail.com", created_at: nil, updated_at: nil>
```

+ `irb(main):004:0> user.valid?`を実行(userオブジェクトが有効かどうか)<br>

```:terminal
=> true
```

+ `irb(main):005:0> user.save`を実行<br>

```:terminal
  TRANSACTION (0.8ms)  SAVEPOINT active_record_1
  User Create (3.9ms)  INSERT INTO "users" ("name", "email", "created_at", "updated_at") VALUES ($1, $2, $3, $4) RETURNING "id"  [["name", "Takaki Nakamura"], ["email", "takaki55730317@gmail.com"], ["created_at", "2022-05-23 05:48:02.793300"], ["updated_at", "2022-05-23 05:48:02.793300"]]
  TRANSACTION (2.6ms)  RELEASE SAVEPOINT active_record_1
=> true
```

+ `irb(main):006:0> user`を実行<br>

```:terminal
=> #<User id: 1, name: "Takaki Nakamura", email: "takaki55730317@gmail.com", created_at: "2022-05-23 05:48:02.793300000 +0000", updated_at: "2022-05-23 05:48:02.793300000 +0000">
```

+ `irb(main):007:0> user.name`を実行<br>

```:terminal
=> "Takaki Nakamura"
```

+ `irb(main):008:0> user.email`を実行<br>

```:terminal
=> "takaki55730317@gmail.com"
```

+ `irb(main):009:0> user.updated_at`を実行<br>

```:terminal
=> Mon, 23 May 2022 05:48:02.793300000 UTC +00:00
```

+ `irb(main):011:0> User.create(name: "A Nother", email: "another@example.org")`を実行<br>

```:terminal
  TRANSACTION (0.6ms)  SAVEPOINT active_record_1
  User Create (1.3ms)  INSERT INTO "users" ("name", "email", "created_at", "updated_at") VALUES ($1, $2, $3, $4) RETURNING "id"  [["name", "A Nother"], ["email", "another@example.org"], ["created_at", "2022-05-23 05:52:52.882744"], ["updated_at", "2022-05-23 05:52:52.882744"]]
  TRANSACTION (0.9ms)  RELEASE SAVEPOINT active_record_1
=> #<User id: 2, name: "A Nother", email: "another@example.org", created_at: "2022-05-23 05:52:52.882744000 +0000", updated_at: "2022-05-23 05:52:52.882744000 +0000">
```

+ `irb(main):013:0> foo = User.create(name: "Foo", email: "foo@bar.com")`を実行<br>

```:terminal
  TRANSACTION (1.1ms)  SAVEPOINT active_record_1
  User Create (0.8ms)  INSERT INTO "users" ("name", "email", "created_at", "updated_at") VALUES ($1, $2, $3, $4) RETURNING "id"  [["name", "Foo"], ["email", "foo@bar.com"], ["created_at", "2022-05-23 05:54:06.750574"], ["updated_at", "2022-05-23 05:54:06.750574"]]
  TRANSACTION (0.7ms)  RELEASE SAVEPOINT active_record_1
=> #<User id: 3, name: "Foo", email: "foo@bar.com", created_at: "2022-05-23 05:54:06.750574000 +0000", updated_at: "2022-05-23 05:54:06.750574000 +0000">
```

+ `irb(main):015:0> foo.destroy`を実行<br>

```:terminal
  TRANSACTION (1.4ms)  SAVEPOINT active_record_1
  User Destroy (2.3ms)  DELETE FROM "users" WHERE "users"."id" = $1  [["id", 3]]
  TRANSACTION (0.5ms)  RELEASE SAVEPOINT active_record_1
=> #<User id: 3, name: "Foo", email: "foo@bar.com", created_at: "2022-05-23 05:54:06.750574000 +0000", updated_at: "2022-05-23 05:54:06.750574000 +0000">
```

+ `irb(main):017:0> foo`を実行(まだ下記のようにメモリー上に残っている)<br>

```:terminal
=> #<User id: 3, name: "Foo", email: "foo@bar.com", created_at: "2022-05-23 05:54:06.750574000 +0000", updated_at: "2022-05-23 05:54:06.750574000 +0000">
```

# 6.1.4 ユーザーオブジェクトを検索する

+ `irb(main):019:0> User.find(1)`を実行<br>

```:terminal
  User Load (0.4ms)  SELECT "users".* FROM "users" WHERE "users"."id" = $1 LIMIT $2  [["id", 1], ["LIMIT", 1]]
=> #<User id: 1, name: "Takaki Nakamura", email: "takaki55730317@gmail.com", created_at: "2022-05-23 05:48:02.793300000 +0000", updated_at: "2022-05-23 05:48:02.793300000 +0000">
```

+ `irb(main):021:0> User.find(3)`を実行<br>

```:terminal
  User Load (1.4ms)  SELECT "users".* FROM "users" WHERE "users"."id" = $1 LIMIT $2  [["id", 3], ["LIMIT", 1]]
Traceback (most recent call last):
        1: from (irb):21
ActiveRecord::RecordNotFound (Couldn't find User with 'id'=3)
```

+ `irb(main):024:0> User.find_by(email: "takaki55730317@gmail.com")`を実行<br>

```:terminal
  User Load (0.8ms)  SELECT "users".* FROM "users" WHERE "users"."email" = $1 LIMIT $2  [["email", "takaki55730317@gmail.com"], ["LIMIT", 1]]
=> #<User id: 1, name: "Takaki Nakamura", email: "takaki55730317@gmail.com", created_at: "2022-05-23 05:48:02.793300000 +0000", updated_at: "2022-05-23 05:48:02.793300000 +0000">
```

+ `irb(main):026:0> User.first`を実行<br>

```:terminal
  User Load (1.7ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" ASC LIMIT $1  [["LIMIT", 1]]
=> #<User id: 1, name: "Takaki Nakamura", email: "takaki55730317@gmail.com", created_at: "2022-05-23 05:48:02.793300000 +0000", updated_at: "2022-05-23 05:48:02.793300000 +0000">
```

+ `irb(main):028:0> User.all`を実行<br>

```:terminal
  User Load (0.6ms)  SELECT "users".* FROM "users" /* loading for inspect */ LIMIT $1  [["LIMIT", 11]]
=> #<ActiveRecord::Relation [#<User id: 1, name: "Takaki Nakamura", email: "takaki55730317@gmail.com", created_at: "2022-05-23 05:48:02.793300000 +0000", updated_at: "2022-05-23 05:48:02.793300000 +0000">, #<User id: 2, name: "A Nother", email: "another@example.org", created_at: "2022-05-23 05:52:52.882744000 +0000", updated_at: "2022-05-23 05:52:52.882744000 +0000">]>
```

# 6.1.5 ユーザーオブジェクトを更新する

+ `irb(main):031:0> user`を実行<br>

```:terminal
=> #<User id: 1, name: "Takaki Nakamura", email: "takaki55730317@gmail.com", created_at: "2022-05-23 05:48:02.793300000 +0000", updated_at: "2022-05-23 05:48:02.793300000 +0000">
```

+ `irb(main):033:0> user.email = "takaki55730317@example.com"`を実行<br>

```:terminal
=> "takaki55730317@example.com"
```

+ `irb(main):034:0> user.save`を実行<br>

```:terminal
  TRANSACTION (0.4ms)  SAVEPOINT active_record_1
  User Update (0.7ms)  UPDATE "users" SET "email" = $1, "updated_at" = $2 WHERE "users"."id" = $3  [["email", "takaki55730317@example.com"], ["updated_at", "2022-05-23 06:07:36.583314"], ["id", 1]]
  TRANSACTION (0.6ms)  RELEASE SAVEPOINT active_record_1
=> true
```

※ user.saveを行わずに`reload`を実行するとデータベースの情報を元にオブジェクトを再読み込みするので変更が取り消される<br>

+ `irb(main):035:0> user.created_at`を実行<br>

```:terminal
=> Mon, 23 May 2022 05:48:02.793300000 UTC +00:00
```

+ `irb(main):036:0> user.updated_at`を実行<br>

```:terminal
=> Mon, 23 May 2022 06:07:36.583314000 UTC +00:00
```

+ `irb(main):038:0> user.update(name: "The Dude", email: "dude@abides.org")`を実行<br>

```:terminal
 TRANSACTION (1.4ms)  SAVEPOINT active_record_1
  User Update (2.2ms)  UPDATE "users" SET "name" = $1, "email" = $2, "updated_at" = $3 WHERE "users"."id" = $4  [["name", "The Dude"], ["email", "dude@abides.org"], ["updated_at", "2022-05-23 06:12:09.972162"], ["id", 1]]
  TRANSACTION (1.7ms)  RELEASE SAVEPOINT active_record_1
=> true
```

+ `irb(main):039:0> user.name`を実行<br>

```:terminal
=> "The Dude"
```

+ `irb(main):042:0> user.email`を実行<br>

```:terminal
=> "dude@abides.org"
```

+ `irb(main):043:0> user.update_attribute(:name, "El Duderino")`を実行<br>

```:terminal
  TRANSACTION (0.4ms)  SAVEPOINT active_record_1
  User Update (1.1ms)  UPDATE "users" SET "name" = $1, "updated_at" = $2 WHERE "users"."id" = $3  [["name", "El Duderino"], ["updated_at", "2022-05-23 06:15:55.322865"], ["id", 1]]
  TRANSACTION (0.4ms)  RELEASE SAVEPOINT active_record_1
=> true
```

+ `irb(main):044:0> user.name`を実行<br>

```:terminal
=> "El Duderino"
```

# 6.2 ユーザーを検証する

## リスト 6.5: 有効なUserがどうかをテストする

+ `test/models/user_test.rb`を編集<br>

```rb:user_test.rb
require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com")
  end

  test "should be valid" do
    assert @user.valid?
  end
end
```

+ `$ docker compose run --rm web rails test:models`を実行<br>

```:terminal
[+] Running 1/0
 ⠿ Container rails-db  Running                                                                                                                                                                                                       0.0s
Running via Spring preloader in process 20
Started with run options --seed 5157

  1/1: [=============================================================================================================================================================================================] 100% Time: 00:00:00, Time: 00:00:00

Finished in 1.05638s
1 tests, 1 assertions, 0 failures, 0 errors, 0 skips
```

# 6.2.2 存在性を検証する

## リスト 6.7: name属性にバリデーションに対するテスト(RED)

+ `test/models/user_test.rb`を編集<br>

```rb:user_test.rb
require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "    "
    assert_not @user.valid?
  end
end
```

+ `$ docker compose run --rm web rails test:models`を実行<br>

```:terminal
 FAIL UserTest#test_name_should_be_present (0.34s)
        Expected true to be nil or false
        test/models/user_test.rb:15:in `block in <class:UserTest>'

  2/2: [=====================================================================================================================================================================] 100% Time: 00:00:00, Time: 00:00:00

Finished in 0.43922s
2 tests, 2 assertions, 1 failures, 0 errors, 0 skips
```

## リスト 6.9: name属性の存在性を検証する(GREEN)

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  validates :name, presence: true
end
```

+ `$ docker compose rum --rm web rails console --sandbox`を実行<br>

+ `irb(main):001:0> user = User.new(name: "", email: "takaki@example.com")`を実行<br>

```:terminal
  TRANSACTION (0.3ms)  BEGIN
=> #<User id: nil, name: "", email: "takaki@example.com", created_at: nil, updated_at: nil>
```

+ `irb(main):002:0> user.valid?`を実行<br>

```:terminal
=> false
```

+ `irb(main):003:0> user.errors.full_messages`を実行<br>

```:terminal
=> ["Name can't be blank"]
```

+ `irb(main):004:0> user.save`を実行<br>

```:terminal
=> false
```

+ `$ docker compose run --rm web rails test:models`を実行(GREEN)<br>


```:terminal
Started with run options --seed 19381

  2/2: [=====================================================================================================================================================================] 100% Time: 00:00:00, Time: 00:00:00

Finished in 0.41319s
2 tests, 2 assertions, 0 failures, 0 errors, 0 skips
```

## リスト 6.11: email属性の検証に対するテスト(RED)

+ `test/models/user_test.rb`を編集<br>

```rb:user_test.rb
require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com")
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
end
```

+ `$ rails test:model`を実行<br>

```:terminal
Started with run options --seed 53342

 FAIL UserTest#test_email_should_be_present (0.32s)
        Expected true to be nil or false
        test/models/user_test.rb:20:in `block in <class:UserTest>'

  3/3: [=====================================================================================================================================================================] 100% Time: 00:00:00, Time: 00:00:00

Finished in 0.53774s
3 tests, 3 assertions, 1 failures, 0 errors, 0 skips
```

## リスト 6.12: email属性の存在性を検証する(GREEN)

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true
end
```

+ `$ rails test`を実行<br>

```:terminal
Running via Spring preloader in process 56
Started with run options --seed 15299

  9/9: [=====================================================================================================================================================================] 100% Time: 00:00:02, Time: 00:00:02

Finished in 2.27585s
9 tests, 20 assertions, 0 failures, 0 errors, 0 skips
```

# 6.2.3 長さを検証する

## リスト 6.1.4: name と email の長さの検証に対するテスト(RED)

+ `test/models/user_test.rb`を実行<br>

```rb:user_test.rb
require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com")
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
end
```

+ `$ rails test`を実行<br>

```:terminal
Running via Spring preloader in process 78
Started with run options --seed 54441

 FAIL UserTest#test_email_should_not_be_too_long (1.88s)
        Expected true to be nil or false
        test/models/user_test.rb:30:in `block in <class:UserTest>'

 FAIL UserTest#test_name_should_not_be_too_long (1.90s)
        Expected true to be nil or false
        test/models/user_test.rb:25:in `block in <class:UserTest>'

  11/11: [===================================================================================================================================================================] 100% Time: 00:00:01, Time: 00:00:01

Finished in 2.03579s
11 tests, 22 assertions, 2 failures, 0 errors, 0 skips
```

## リスト 6.16: name 属性に長さの検証を追加する(GREEN)

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 }
end
```

+ `$ rails test`を実行<br>

```:terminal
Running via Spring preloader in process 91
Started with run options --seed 17624

  11/11: [===================================================================================================================================================================] 100% Time: 00:00:01, Time: 00:00:01

Finished in 1.83216s
11 tests, 22 assertions, 0 failures, 0 errors, 0 skips
```

# 6.2.4 フォーマットを検証する

## リスト 6.18: 有効なメールフォーマットをテストする(GREEN)

+ `test/models/user_test.rb`を編集<br>

```rb:user_test.rb
require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com")
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

  # 追加
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
      first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end
end
```

+ `$ rails test`を実行<br>

```:terminal
Running via Spring preloader in process 110
Started with run options --seed 11043

  12/12: [===================================================================================================================================================================] 100% Time: 00:00:02, Time: 00:00:02

Finished in 2.15244s
12 tests, 27 assertions, 0 failures, 0 errors, 0 skips
```

## リスト 6.19: メールフォーマットの検証に対するテスト(RED)

+ `test/models/user_test.rb`を編集<br>

```rb:user_test.rb
require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com")
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

  # 追加
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
      foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end
end
```

+ `$ rails test`を実行<br>

```:terminal
Running via Spring preloader in process 123
Started with run options --seed 7197

 FAIL UserTest#test_email_validation_should_reject_invalid_addresses (0.36s)
        "user@example,com" should be invalid
        test/models/user_test.rb:47:in `block (2 levels) in <class:UserTest>'
        test/models/user_test.rb:45:in `each'
        test/models/user_test.rb:45:in `block in <class:UserTest>'

  13/13: [===================================================================================================================================================================] 100% Time: 00:00:01, Time: 00:00:01

Finished in 1.76129s
13 tests, 28 assertions, 1 failures, 0 errors, 0 skips
```

## リスト 6.21: メールフォーマットを正規表現で検証する(GREEN)

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i # 追加
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX } # 追加
end
```

+ `$ rails test`を実行<br>

```:terminal
Running via Spring preloader in process 160
Started with run options --seed 29857

  13/13: [===================================================================================================================================================================] 100% Time: 00:00:01, Time: 00:00:01

Finished in 1.87181s
13 tests, 32 assertions, 0 failures, 0 errors, 0 skips
```

## リスト 6.23: 2つの連続したドットはマッチさせないようにする(GREEN)

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i # 編集
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX }
end
```

+ `$ rails test`を実行<br>

```:terminal
Running via Spring preloader in process 172
Started with run options --seed 54639

  13/13: [===================================================================================================================================================================] 100% Time: 00:00:02, Time: 00:00:02

Finished in 2.45594s
13 tests, 32 assertions, 0 failures, 0 errors, 0 skips
```

# 6.2.5 一意性を検証する

## リスト 6.24: 重複するメールアドレス拒否のテスト(RED)

+ `test/models/user_test.rb`を編集<br>

```rb:user_test.rb
require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com")
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

  # 追加
  test "email addresses should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end
end
```

+ `$ rails test`を実行<br>

```:terminal
Running via Spring preloader in process 184
Started with run options --seed 43399

 FAIL UserTest#test_email_addresses_should_be_unique (1.77s)
        Expected true to be nil or false
        test/models/user_test.rb:54:in `block in <class:UserTest>'

  14/14: [===================================================================================================================================================================] 100% Time: 00:00:01, Time: 00:00:01

Finished in 1.95162s
14 tests, 33 assertions, 1 failures, 0 errors, 0 skips
```
## リスト 6.25: メールアドレスの一意性を検証する(GREEN)

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true # 追加
end
```

+ `$ rails test`を実行<br>

```:terminal
Running via Spring preloader in process 196
Started with run options --seed 63554

  14/14: [===================================================================================================================================================================] 100% Time: 00:00:01, Time: 00:00:01

Finished in 1.95914s
14 tests, 33 assertions, 0 failures, 0 errors, 0 skips
```

## リスト 6.16: 大文字小文字を区別しない、一意性のテスト(RED)

+ `test/models/user_test.rb`を編集<br>

```rb:user_test.rb
require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com")
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
    duplicate_user.email = @user.email.upcase # 追加
    @user.save
    assert_not duplicate_user.valid?
  end
end
```

+ `$ rails test`を実行<br>

```:terminal
Started with run options --seed 13367

 FAIL UserTest#test_email_addresses_should_be_unique (0.85s)
        Expected true to be nil or false
        test/models/user_test.rb:55:in `block in <class:UserTest>'

  14/14: [===================================================================================================================================================================] 100% Time: 00:00:02, Time: 00:00:02

Finished in 2.15937s
14 tests, 33 assertions, 1 failures, 0 errors, 0 skips
```

+ `$ rails console --sandbox`を実行<br>

+ `irb(main):001:0> user = User.create(name: "Example User", email: "user@example.com")`を実行<br>

```:terminal
  TRANSACTION (0.4ms)  BEGIN
  TRANSACTION (0.6ms)  SAVEPOINT active_record_1
  User Exists? (2.2ms)  SELECT 1 AS one FROM "users" WHERE "users"."email" = $1 LIMIT $2  [["email", "user@example.com"], ["LIMIT", 1]]
  User Create (2.8ms)  INSERT INTO "users" ("name", "email", "created_at", "updated_at") VALUES ($1, $2, $3, $4) RETURNING "id"  [["name", "Example User"], ["email", "user@example.com"], ["created_at", "2022-05-23 07:35:35.684362"], ["updated_at", "2022-05-23 07:35:35.684362"]]
  TRANSACTION (2.0ms)  RELEASE SAVEPOINT active_record_1
=> #<User id: 5, name: "Example User", email: "user@example.com", created_at: "2022-05-23 07:35:35.684362000 +0000", updated_at: "2022-05-23 07:35:35.684362000 +0000">
```

+ `irb(main):003:0> user.email.upcase`を実行<br>

```:terminal
=> "USER@EXAMPLE.COM"
```

+ `irb(main):005:0> duplicate_user = user.dup`を実行<br>

```:terminal
=> #<User id: nil, name: "Example User", email: "user@example.com", created_at: nil, updated_at: nil>
```

+ `irb(main):007:0> duplicate_user.email = user.email.upcase`を実行<br>

```:terminal
=> "USER@EXAMPLE.COM"
```

+ `irb(main):008:0> duplicate_user.valid?`を実行<br>

```:terminal
  User Exists? (1.3ms)  SELECT 1 AS one FROM "users" WHERE "users"."email" = $1 LIMIT $2  [["email", "USER@EXAMPLE.COM"], ["LIMIT", 1]]
=> true
```

## リスト 6.27: メールアドレスの大文字小文字を無視した一意性の検証(GREEN)

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false } # 編集
end
```

+ `$ rails test`を実行<br>

```:terminal
Running via Spring preloader in process 263
Started with run options --seed 52867

  14/14: [===================================================================================================================================================================] 100% Time: 00:00:01, Time: 00:00:01

Finished in 1.94324s
14 tests, 33 assertions, 0 failures, 0 errors, 0 skips
```

+ `$ rails g migration add_index_to_users_email`を実行<br>

## リスト 6.29: メールアドレスの一意性を強制するためのマイグレーション

+ `db/migrate/add_index_to_users_email.rb`を編集<br>

```rb:add_index_to_users_email.rb
class AddIndexToUsersEmail < ActiveRecord::Migration[6.1]
  def change
    add_index :users, :email, unique: true # 追加
  end
end
```

+ `$ rails db:migrate`を実行<br>

+ `$ rails test`を実行<br>

```:terminal
  14/14: [===================================================================================================================================================================] 100% Time: 00:00:02, Time: 00:00:02

Finished in 2.17500s
14 tests, 0 assertions, 0 failures, 14 errors, 0 skips
```

## リスト 6.31: 空のfixtureファイル(GREEN)

+ `test/fixtures/users.yml`の中身を空にする<br>

+ `$ rails test`を実行<br>

```:terminal
Running via Spring preloader in process 310
Started with run options --seed 53611

  14/14: [===================================================================================================================================================================] 100% Time: 00:00:01, Time: 00:00:01

Finished in 1.84662s
14 tests, 33 assertions, 0 failures, 0 errors, 0 skips
```

## リスト 6.32: email属性を小文字に変換してメールアドレスの一意性を保証する(GREEN)

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  before_save { self.email = email.downcase } # 追加
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
end
```

+ `$ rails test`を実行<br>

```:terminal
Running via Spring preloader in process 322
Started with run options --seed 17134

  14/14: [===================================================================================================================================================================] 100% Time: 00:00:01, Time: 00:00:01

Finished in 1.97418s
14 tests, 33 assertions, 0 failures, 0 errors, 0 skips
```

## リスト 6.33: リスト 6.32のメールアドレスの小文字化に対するテスト

+ `test/models/user_test.rb`を編集<br>

```rb:user_test.rb
require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com")
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
end
```

+ `$ rails test`を実行<br>

```:terminal
Running via Spring preloader in process 334
Started with run options --seed 2673

  15/15: [===================================================================================================================================================================] 100% Time: 00:00:01, Time: 00:00:01

Finished in 2.03222s
15 tests, 34 assertions, 0 failures, 0 errors, 0 skips
```

## リスト 6.34: もう１つのコールバック処理の実装方法(GREEN)

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  before_save { email.downcase! } # 編集
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
end
```

+ `$ rails test`を実行<br>

```:terminal
Running via Spring preloader in process 346
Started with run options --seed 31983

  15/15: [===================================================================================================================================================================] 100% Time: 00:00:01, Time: 00:00:01

Finished in 1.95069s
15 tests, 34 assertions, 0 failures, 0 errors, 0 skips
```
