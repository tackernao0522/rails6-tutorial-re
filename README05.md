# 6.3 セキュアなパスワードを追加する

## 6.3.1 ハッシュ化されたパスワード

+ `$ rails g migration add_password_digest_to_users password_digest:string`を実行<br>

+ `$ rails db:migrate`を実行<br>

## リスト 6.36: `bcrypt` を `Gemfile` に追加する

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
gem 'bcrypt', '~> 3.1.7' # コメントアウト解除

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

## リスト 6.37: Userモデルに `has_secure_password`を追加する(RED)

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password # 追加
end
```

+ `$ rails test`を実行<br>

```:terminal
Running via Spring preloader in process 17
Running via Spring preloader in process 22
Started with run options --seed 48848

 FAIL UserTest#test_email_validation_should_accept_valid_addresses (2.89s)
        "user@example.com" should be valid
        test/models/user_test.rb:38:in `block (2 levels) in <class:UserTest>'
        test/models/user_test.rb:36:in `each'
        test/models/user_test.rb:36:in `block in <class:UserTest>'

ERROR UserTest#test_email_addresses_should_be_saved_ad_lower-case (3.02s)
Minitest::UnexpectedError:         ActiveRecord::RecordNotFound: Couldn't find User without an ID
            test/models/user_test.rb:62:in `block in <class:UserTest>'

 FAIL UserTest#test_should_be_valid (3.25s)
        Expected false to be truthy.
        test/models/user_test.rb:10:in `block in <class:UserTest>'

  15/15: [===================================================================================================================================================================] 100% Time: 00:00:03, Time: 00:00:03

Finished in 3.46295s
15 tests, 29 assertions, 2 failures, 1 errors, 0 skips
```

## リスト 6.39: パスワードとパスワード確認を追加する(GREEN)

+ `test/models/user_test.rb`を編集<br>

```rb:user_test.rb
require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                    password: "foobar", password_confirmation: "foobar") # 編集
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
[+] Running 1/0
 ⠿ Container rails-db  Running                                                                                                                                                                               0.0s
Running via Spring preloader in process 16
Started with run options --seed 44539

  15/15: [===================================================================================================================================================================] 100% Time: 00:00:02, Time: 00:00:02

Finished in 2.87996s
15 tests, 34 assertions, 0 failures, 0 errors, 0 skips
```

# 6.3.3 パスワードの最小文字数

## リスト 6.41: パスワードの最小文字数をテストする(RED)

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

  # 追加
  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
  # ここまで
end
```

+ `$ rails test`を実行<br>

```:terminal
 ⠿ Container rails-db  Running                                                                                                                                                                               0.0s
Running via Spring preloader in process 16
Started with run options --seed 5985

 FAIL UserTest#test_password_should_be_present_(nonblank) (1.70s)
        Expected true to be nil or false
        test/models/user_test.rb:68:in `block in <class:UserTest>'

 FAIL UserTest#test_password_should_have_a_minimum_length (1.85s)
        Expected true to be nil or false
        test/models/user_test.rb:73:in `block in <class:UserTest>'

  17/17: [===================================================================================================================================================================] 100% Time: 00:00:02, Time: 00:00:02

Finished in 2.18812s
17 tests, 36 assertions, 2 failures, 0 errors, 0 skips
```

## リスト 6.42: セキュアパスワードの完全な実装(GREEN)

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
  validates :password, presence: true, length: { minimum: 6 } # 追加
end
```

+ `$ rails test:models`を実行<br>

```:terminal
[+] Running 1/0
 ⠿ Container rails-db  Running                                                                                                                                                                               0.0s
Started with run options --seed 19612

  11/11: [===================================================================================================================================================================] 100% Time: 00:00:00, Time: 00:00:00

Finished in 0.83508s
11 tests, 19 assertions, 0 failures, 0 errors, 0 skips
```

## rails consoleでユーザー登録する

+ `$ rails console`を実行<br>

+ `irb(main):001:0> User.create(name: "Takaki Nakamura", email: "takaki55730317@gmail.com", password: "password", password_confirmation: "password")`を実行<br>

```:terminal
  TRANSACTION (0.5ms)  BEGIN
  User Exists? (1.6ms)  SELECT 1 AS one FROM "users" WHERE LOWER("users"."email") = LOWER($1) LIMIT $2  [["email", "takaki55730317@gmail.com"], ["LIMIT", 1]]
  User Create (1.5ms)  INSERT INTO "users" ("name", "email", "created_at", "updated_at", "password_digest") VALUES ($1, $2, $3, $4, $5) RETURNING "id"  [["name", "Takaki Nakamura"], ["email", "takaki55730317@gmail.com"], ["created_at", "2022-05-23 09:42:40.571675"], ["updated_at", "2022-05-23 09:42:40.571675"], ["password_digest", "$2a$12$BqCkiF1CGx0D6MINTmWvoed7gv0LKDfXiPPJVNTX3Ha3KjY4lZArm"]]
  TRANSACTION (3.7ms)  COMMIT
=> #<User id: 6, name: "Takaki Nakamura", email: "takaki55730317@gmail.com", created_at: "2022-05-23 09:42:40.571675000 +0000", updated_at: "2022-05-23 09:42:40.571675000 +0000", password_digest: [FILTERED]>
```

+ `$ rails c`を実行<br>

+ `irb(main):001:0> user = User.find_by(email: "takaki55730317@gmail.com")`を実行<br>

```:terminal
  User Load (0.5ms)  SELECT "users".* FROM "users" WHERE "users"."email" = $1 LIMIT $2  [["email", "takaki55730317@gmail.com"], ["LIMIT", 1]]
=> #<User id: 6, name: "Takaki Nakamura", email: "takaki55730317@gmail.com", created_at: "2022-05-23 09:42:40.571675000 +0000", updated_at: "2022-05-23 09:42:40.571675000 +0000", password_digest: [FILTERED]>
```

+ `irb(main):003:0> user.password_digest`を実行<br>

```:terminal
=> "$2a$12$BqCkiF1CGx0D6MINTmWvoed7gv0LKDfXiPPJVNTX3Ha3KjY4lZArm"
```

## 間違えたパスワードを入れてみる

+ `irb(main):004:0> user.authenticate("not_the_right_password")`を実行<br>

```:terminal
=> false
```

+ `irb(main):005:0> user.authenticate("foobaz")`を実行<br>

```:terminal
=> false
```

## 正しいパスワードを入れてみる

+ `!!user.authenticate("password")`を実行<br>

```:terminal
=> true
```