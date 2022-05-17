## 4.1.2 カスタムヘルパー

- `app/helpers/application_helper.rb`を編集<br>

```rb:application_helper.rb
module ApplicationHelper

  # パージごとの完全なタイトルを返す
  def full_title(page_title = '')
    base_title = "Ruby on Rails Tutorial Sample App"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end
end
```

+ `app/views/layout/application.html.erb`を編集<br>

```erb:application.html.erb
<!DOCTYPE html>
<html>
  <head>
    <title><%= full_title(yield(:title)) %></title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
  </head>

  <body>
    <%= yield %>
  </body>
</html>
```

+ `$ rails test`を実行<br>

```:terminal
 ⠿ Container rails-db  Running                                                                                                                                                               0.0s
Running via Spring preloader in process 17
Started with run options --seed 16532

  3/3: [=====================================================================================================================================================] 100% Time: 00:00:01, Time: 00:00:01

Finished in 1.29140s
3 tests, 6 assertions, 0 failures, 0 errors, 0 skips
```

+ `test/controllers/static_pages_controller_test.erb`を編集<br>

```rb:static_pages_controller_test.rb
require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest

  test "should get home" do
    get static_pages_home_url
    assert_response :success
    assert_select "title", "Ruby on Rails Tutorial Sample App"
  end

  test "should get help" do
    get static_pages_help_url
    assert_response :success
    assert_select "title", "Help | Ruby on Rails Tutorial Sample App"
  end

  test "should get about" do
    get static_pages_about_url
    assert_response :success
    assert_select "title", "About | Ruby on Rails Tutorial Sample App"
  end
end
```

+ `$ rails test`を実行<br>

```:terminal
 ⠿ Container rails-db  Running                                                                                                                                                               0.0s
Running via Spring preloader in process 16
Started with run options --seed 48682

 FAIL StaticPagesControllerTest#test_should_get_home (1.26s)
        <Ruby on Rails Tutorial Sample App> expected but was
        <Home | Ruby on Rails Tutorial Sample App>..
        Expected 0 to be >= 1.
        test/controllers/static_pages_controller_test.rb:8:in `block in <class:StaticPagesControllerTest>'

  3/3: [=====================================================================================================================================================] 100% Time: 00:00:01, Time: 00:00:01

Finished in 1.37805s
3 tests, 6 assertions, 1 failures, 0 errors, 0 skips
```

+ `app/views/static_pages/home.html.erb`を編集<br>

```erb:home.html.erb
<h1>Sample App</h1>
<p>
  This is the home page for the
  <a href="https://railstutorial.jp/">Ruby on Rails Tutorial</a>
  Sample application.
</p>
```

+ `$ rails test`を実行<br>

```:terminal
[+] Running 1/0
 ⠿ Container rails-db  Running                                                                                                                                                               0.0s
Running via Spring preloader in process 17
Started with run options --seed 1144

  3/3: [=====================================================================================================================================================] 100% Time: 00:00:01, Time: 00:00:01

Finished in 1.32129s
3 tests, 6 assertions, 0 failures, 0 errors, 0 skips
```
## 4.4.5 ユーザークラス

+ `$ touch example_user.rb`を実行<br>

+ `example_user.rb`を編集<br>

```rb:example_user.rb
class User
  attr_accessor :name, :email

  def initialize(attributes = {})
    @name = attributes[:name]
    @email = attributes[:email]
  end

  def formatted_email
    "#{@name} <#{@email}>"
  end
end
```

+ `docker compose run --rm web bash`を実行<br>

+ `/app# env LANG=C.UTF-8 rails c`を実行<br>

+ `> require './example_user'`を実行<br>

```
=> true
```

+ `> example = User.new`を実行<br>

```
=> #<User:0x000055974b2f88d8 @name=nil, @email=nil>
```

+ `> example.name`を実行<br>

```
=> nil
```

+ `> example.name = "Example User"`を実行<br>

```
=> "Example User"
```

+ `> example.email = "user@example.com"`を実行<br>

```
=> "user@example.com"
```

+ `> example.formatted_email`を実行<br>

```
=> "Example User <user@example.com>"
```

+ `> user = User.new(name: "孝樹", email: "takaki@test.com")`を実行<br>

```
=> #<User:0x000055974afb2520 @name="孝樹", @email="takaki@test.com">
```

+ `> user.formatted_email`を実行<br>

```
=> "孝樹 <takaki@test.com>"
```

# 第5章 レイアウトを作成する

## 5.1.1 ナビゲーション

+ `app/views/layouts/application.html.erb`を編集<br>

```erb:application.html.erb
<!DOCTYPE html>
<html>

<head>
  <title><%= full_title(yield(:title)) %></title>
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>

  <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
  <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>

  <!--[if lt IE 9]>
      <script src="//cdnjs.cloudflare.com/ajax/libs/html5shiv/r29/html5.min.js">
      </script>
    <![endif]-->
</head>

<body>
  <header class="navbar navbar-fixed-top navbar-inverse">
    <div class="container">
      <%= link_to "sample app", '#', id: "logo" %>
      <nav>
        <ul class="nav navbar-nav navbar-right">
          <li><%= link_to "Home", '#' %></li>
          <li><%= link_to "Help", '#' %></li>
          <li><%= link_to "Log in", '#' %></li>
        </ul>
      </nav>
    </div>
  </header>
  <div class="container">
    <%= yield %>
  </div>
</body>

</html>
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

  <%= link_to "Sign up now!", '#', class: "btn btn-lg btn-primary" %>
</div>

<%= link_to image_tag("rails.svg", alt: "Rails logo", width: "200px"), "https://rubyonrails.org/" %>
```

+ `app/assets/images`ディレクトリにrails.svgファイルを配置<br>

# 5.1.2 BootstrapとカスタムCSS

+ `Gemfile`を編集<br>

```:Gemfile
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.6'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
gem 'bootstrap-sass', '3.4.1' # 追加
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
# gem 'bcrypt', '~> 3.1.7'

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
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
```

+ `$ docker compose build`を実行<br>

+ `$ touch app/assets/stylesheets/custom.scss`を実行<br>

+ `app/assets/stylesheets/custom.scss`を編集<br>

```scss:custom.scss
@import 'bootstrap-sprockets';
@import 'bootstrap';

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
}

.center h1 {
  margin-bottom: 10px;
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
  color: #777;
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
  color: #fff;
  text-transform: uppercase;
  letter-spacing: -1px;
  padding-top: 9px;
  font-weight: bold;
}

#logo:hover {
  color: #fff;
  text-decoration: none;
}
```

## 5.1.3 パーシャル (partial)

+ `app/views/layouts/application.html.erb`を編集<br>

```erb:application.html.erb
<!DOCTYPE html>
<html>

<head>
  <title><%= full_title(yield(:title)) %></title>
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>

  <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
  <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>

  <%= render 'layouts/shim' %>
</head>

<body>
  <%= render 'layouts/header' %>
  <div class="container">
    <%= yield %>
  </div>
</body>

</html>
```

+ `$ touch app/views/layouts/_header.html.erb`<br>

+ `$ touch app/views/layouts/_shim.html.erb`<br>

```erb:_shim.html.erb
<!--[if lt IE 9]>
  <script src="//cdnjs.cloudflare.com/ajax/libs/html5shiv/r29/html5.min.js">
  </script>
<![endif]-->
```

## リスト 5.15: サイトのfooter用のパーシャルの作成

+ `$ touch app/views/layouts/_footer.html.erb`を実行<br>

```erb:_footer.html.erb
<footer class="footer">
  <small>
    The <a href="https://railstutorial.jp/">Ruby on Rails Tutorial</a>
    by <a href="https://www.michaelhartl.com/">Michael Hartl</a>
  </small>
  <nav>
    <ul>
      <li><%= link_to "About", '#' %></li>
      <li><%= link_to "Contact", "#" %></li>
      <li><a href="https://news.railstutorial.org/">News</a></li>
    </ul>
  </nav>
</footer>
```

## リスト 5.16: レイアウトにfooterパーシャルを追加する

+ `app/views/layouts/application.html.erb`を編集<br>

```erb:application.html.erb
<footer class="footer">
  <small>
    The <a href="https://railstutorial.jp/">Ruby on Rails Tutorial</a>
    by <a href="https://www.michaelhartl.com/">Michael Hartl</a>
  </small>
  <nav>
    <ul>
      <li><%= link_to "About", '#' %></li>
      <li><%= link_to "Contact", "#" %></li>
      # 追加
      <li><a href="https://news.railstutorial.org/">News</a></li>
    </ul>
  </nav>
</footer>
```

## リスト 5.17: サイトにfooter用CSSを追加する

+ `app/assets/stylesheets/custom.scss`を編集<br>

```scss:custom.scss
@import 'bootstrap-sprockets';
@import 'bootstrap';

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
}

.center h1 {
  margin-bottom: 10px;
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
  color: #777;
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
  color: #fff;
  text-transform: uppercase;
  letter-spacing: -1px;
  padding-top: 9px;
  font-weight: bold;
}

#logo:hover {
  color: #fff;
  text-decoration: none;
}

// ここから追加
/* footer */

footer {
  margin-top: 45px;
  padding-top: 5px;
  border-top: 1px solid #eaeaea;
  color: #777;
}

footer a {
  color: #555;
}

footer a:hover {
  color: #222;
}

footer small {
  float: left;
}

footer ul {
  float: right;
  list-style: none;
}

footer ul li {
  float: left;
  margin-left: 15px;
}
```

## リスト 5.20: ネストや変数を使って初期のSCSSファイルを書き直す

+ `app/assets/stylesheets/custom.scss`を編集<br>

```scss:custom.scss
@import "bootstrap-sprockets";
@import "bootstrap";

/* mixins, variables, etc. */

$gray-medium-light: #eaeaea;

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

h1, h2, h3, h4, h5, h6 {
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
```

## Contactページの作成

+ `$ touch app/views/static_pages/contact.html.erb`を実行<br>

+ `app/views/static_pages/contact.html.erb`を編集<br>

```erb:contact.html.erb
<% provide(:title, "Contact") %>
<h1>Contact</h1>
<p>
  Contact the Ruby on Rails Tutorial about the sample app at the
  <a href="https://railstutorial.jp/contact">contact page</a>.
</p>
```

## リスト 5.21: Contactページのテスト

+ `test/controllers/static_pages_controller_test.rb`を編集<br>

```rb:static_pages_controller_test.rb
require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest

  test "should get home" do
    get static_pages_home_url
    assert_response :success
    assert_select "title", "Ruby on Rails Tutorial Sample App"
  end

  test "should get help" do
    get static_pages_help_url
    assert_response :success
    assert_select "title", "Help | Ruby on Rails Tutorial Sample App"
  end

  test "should get about" do
    get static_pages_about_url
    assert_response :success
    assert_select "title", "About | Ruby on Rails Tutorial Sample App"
  end

  # 追加
  test "should get contact" do
    get static_pages_contact_url
    assert_response :success
    assert_select "title", "Contact | Ruby on Rails Tutorial Sample App"
  end
end
```

+ `$ docker compose run --rm web rails test`を実行<br>

```:terminal
  3/3: [=======================================================================================================================================================] 100% Time: 00:00:06, Time: 00:00:06

Finished in 6.52126s
3 tests, 6 assertions, 0 failures, 0 errors, 0 skips
groovy@groovy-no-MacBook-Pro rails6-tutorial % docker compose run --rm web rails test
[+] Running 1/0
 ⠿ Container rails-db  Running                                                                                                                                                                 0.0s
Running via Spring preloader in process 18
Started with run options --seed 42820

ERROR StaticPagesControllerTest#test_should_get_contact (1.93s)
Minitest::UnexpectedError:         NameError: undefined local variable or method `static_pages_contact_url' for #<StaticPagesControllerTest:0x0000558cbf16b240>
            test/controllers/static_pages_controller_test.rb:24:in `block in <class:StaticPagesControllerTest>'

  4/4: [=======================================================================================================================================================] 100% Time: 00:00:04, Time: 00:00:04

Finished in 4.19721s
4 tests, 6 assertions, 0 failures, 1 errors, 0 skips
```

## リスト 5.2.3: Contactページのルートを追加する

+ `config/routes.rb`を編集<br>

```rb:routes.rb
Rails.application.routes.draw do
  root 'static_pages#home'
  get 'static_pages/home'
  get 'static_pages/help'
  get 'static_pages/about'
  get 'static_pages/contact' # 追加
end
```

+ `app/controllers/static_pages_controller.rb`を編集<br>

```rb:static_pages_controller.rb
class StaticPagesController < ApplicationController
  def home
  end

  def help
  end

  def about
  end

  def contact
  end
end
```

+ `$ docker compose run --rm web rails test`を実行<br>


```:terminal
 ⠿ Container rails-db  Running                                                                                                                                                                 0.0s
Running via Spring preloader in process 18
Started with run options --seed 5057

  4/4: [=======================================================================================================================================================] 100% Time: 00:00:04, Time: 00:00:04

Finished in 4.11700s
4 tests, 8 assertions, 0 failures, 0 errors, 0 skips
```

## リスト 5.27: 静的なページのルーティング一覧(名前付きルーティングに変更)

+ `config/routes.rb`を編集<br>

```rb:routes.rb
Rails.application.routes.draw do
  root 'static_pages#home'
  get '/help',    to: 'static_pages#help'
  get '/about',   to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
end
```

## リスト 5.28: StaticPagesで扱う新しい名前付きルートに対するテスト

`test/controller/static_pages_controller_test.rb`を編集<br>

```rb:static_pages_controller_test.rb
require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest

  test "should get home" do
    get root_path # 編集
    assert_response :success
    assert_select "title", "Ruby on Rails Tutorial Sample App"
  end

  test "should get help" do
    get help_path # 編集
    assert_response :success
    assert_select "title", "Help | Ruby on Rails Tutorial Sample App"
  end

  test "should get about" do
    get about_path # 編集
    assert_response :success
    assert_select "title", "About | Ruby on Rails Tutorial Sample App"
  end

  test "should get contact" do
    get contact_path # 編集
    assert_response :success
    assert_select "title", "Contact | Ruby on Rails Tutorial Sample App"
  end
end
```

+ `$ docker compose run --rm web rails test`を実行<br>

```:terminal
Running via Spring preloader in process 110
Started with run options --seed 21704

  4/4: [========================================================================================================================================================================] 100% Time: 00:00:07, Time: 00:00:07

Finished in 7.05876s
4 tests, 8 assertions, 0 failures, 0 errors, 0 skips
```

## リスト 5.30: headerパーシャルにリンクを追加する

`app/views/layouts/_header.html.erb`を編集<br>

```erb:_header.html.erb
<header class="navbar navbar-fixed-top navbar-inverse">
  <div class="container">
    # 編集
    <%= link_to "sample app", root_path, id: "logo" %>
    <nav>
      <ul class="nav navbar-nav navbar-right">
        <li><%= link_to "Home",   root_path %></li> # 編集
        <li><%= link_to "Help",   help_path %></li> # 編集
        <li><%= link_to "Log in", '#' %></li>
      </ul>
    </nav>
  </div>
</header>
```

## リスト 5.31: footerパーシャルにリンクを追加する

+ `app/views/layouts/_footer.html.erb`を編集<br>

```erb:_footer.html.erb
<footer class="footer">
  <small>
    The <a href="https://railstutorial.jp/">Ruby on Rails Tutorial</a>
    by <a href="https://www.michaelhartl.com/">Michael Hartl</a>
  </small>
  <nav>
    <ul>
      <li><%= link_to "About", about_path %></li> # 編集
      <li><%= link_to "Contact", contact_path %></li> # 編集
      <li><a href="https://news.railstutorial.org/">News</a></li>
    </ul>
  </nav>
</footer>
```

# 5.3.4 リンクのテスト

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
# gem 'bcrypt', '~> 3.1.7'

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
  gem 'rails-controller-testing', '1.0.4' # 追加
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
```

+ `$ docker compose build`を実行<br>

+ `$ docker compose run --rm web rails g integration_test site_layout`を実行<br>

## リスト 5.32: レイアウトのリンクに対するテスト

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
  end
end
```

+ `$ docker compose run --rm web rails test:integration`を実行<br>

```:terminal
Started with run options --seed 5706

  1/1: [========================================================================================================================================================================] 100% Time: 00:00:08, Time: 00:00:08

Finished in 8.25800s
1 tests, 5 assertions, 0 failures, 0 errors, 0 skips
```

+ `$ docker compose run --rm web rails test`を実行<br>

```:terminal
Started with run options --seed 5867

  5/5: [========================================================================================================================================================================] 100% Time: 00:00:06, Time: 00:00:06

Finished in 6.88242s
5 tests, 13 assertions, 0 failures, 0 errors, 0 skips
```

## リスト 5.36: test環境で`full_title`ヘルパーを使う

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
  include ApplicationHelper # 追加

  # Add more helper methods to be used by all tests here...
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
    get contact_path # 追加
    assert_select "title", full_title("Contact") # 追加
  end
end
```

+ `$ docker compose run --rm web rails test`を実行<br>

```:terminal
Running via Spring preloader in process 46
Started with run options --seed 36487

  5/5: [========================================================================================================================================================================] 100% Time: 00:00:04, Time: 00:00:04

Finished in 4.93026s
5 tests, 14 assertions, 0 failures, 0 errors, 0 skips
```
