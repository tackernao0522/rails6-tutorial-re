## 3.4 少しだけ動的なページ

+ `$ mv app/views/layouts/application.html.erb layout_file`を実行<br>

## 3.4.1 タイトルをテストする

+ `test/controllers/static_pages_controller_test.rb`を編集<br>

```rb:static_pages_controller_test.rb
require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get static_pages_home_url
    assert_response :success
    assert_select "title", "Home | Ruby on Rails Tutorial Sample App"
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

```terminal
[+] Running 1/0
 ⠿ Container rails-db  Running                                                                                                                                                                                0.0s
Running via Spring preloader in process 17
Run options: --seed 49963

# Running:

E

Error:
StaticPagesControllerTest#test_should_get_home:
NoMethodError: undefined method `assert_slect' for #<StaticPagesControllerTest:0x000055fbf4b75ef8>
    test/controllers/static_pages_controller_test.rb:7:in `block in <class:StaticPagesControllerTest>'


rails test test/controllers/static_pages_controller_test.rb:4

E

Error:
StaticPagesControllerTest#test_should_get_help:
NoMethodError: undefined method `assert_slect' for #<StaticPagesControllerTest:0x000055fbf4b75c50>
    test/controllers/static_pages_controller_test.rb:13:in `block in <class:StaticPagesControllerTest>'


rails test test/controllers/static_pages_controller_test.rb:10

E

Error:
StaticPagesControllerTest#test_should_get_about:
NoMethodError: undefined method `assert_slect' for #<StaticPagesControllerTest:0x000055fbf525af20>
    test/controllers/static_pages_controller_test.rb:19:in `block in <class:StaticPagesControllerTest>'


rails test test/controllers/static_pages_controller_test.rb:16



Finished in 1.684460s, 1.7810 runs/s, 1.7810 assertions/s.
3 runs, 3 assertions, 0 failures, 3 errors, 0 skips
```

## 3.4.2 タイトルを追加する

+ app/views/static_pages/home.html.erb`を編集<br>

```erb:home.html.erb
<!DOCTYPE html>
<html>

<head>
  <title>Home | Ruby on Rails Tutorial Sample App</title>
</head>

<body>
  <h1>Sample App</h1>
  <p>
    This is the home page for the
    <a href="https://railstutorial.jp/">Ruby on Rails Tutorial</a>
    Sample application.
  </p>
</body>

</html>
```

+ `app/views/static_pages/help.html.erb`を編集<br>

```erb:help.html.erb
<!DOCTYPE html>
<html>

<head>
  <title>Help | Ruby on Rails Tutorial Sample App</title>
</head>

<body>
  <h1>Help</h1>
  <p>
    Get help on the Ruby on Rails Tutorial at the
    <a href="https://railstutorial.jp/help">Rails Tutorial help page</a>.
    To get help on this sample app, see the
    <a href="https://railstutorial.jp/#ebook"><em>Ruby on Rails Tutorial</em>
      book</a>.
  </p>
</body>

</html>
```

+ `app/views/static_pages/about.html.erb`を実行<br>

```erb:about.html.erb
<!DOCTYPE html>
<html>

<head>
  <title>About | Ruby on Rails Tutorial Sample App</title>
</head>

<body>
  <h1>About</h1>
  <p>
    <a href="https://railstutorial.jp/">Ruby on Rails Tutorial</a>
    is a <a href="https://railstutorial.jp/#ebook">book</a> and
    to teach web development with
    <a href="https://rubyonrails.org/">Ruby on Rails</a>.
    This is the sample application for the tutorial.
  </p>
</body>

</html>
```

+ `$ rails test`を実行<br>

```:terminal
[+] Running 1/0
 ⠿ Container rails-db  Running                                                                                                                                                                                0.0s
Running via Spring preloader in process 17
Run options: --seed 52624

# Running:

...

Finished in 1.533440s, 1.9564 runs/s, 3.9128 assertions/s.
3 runs, 6 assertions, 0 failures, 0 errors, 0 skips
```

## 3.4.3 レイアウトと埋め込みRuby (Refactor)

+ `test/controllers/static_pages_controller.rb`を編集<br>

```rb:static_padges_controller.rb
require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest

  # 追加
  def setup
    @base_title = "Ruby on Rails Tutorial Sample App"
  end

  test "should get home" do
    get static_pages_home_url
    assert_response :success
    assert_select "title", "Home | #{@base_title}" # 編集
  end

  test "should get help" do
    get static_pages_help_url
    assert_response :success
    assert_select "title", "Help | #{@base_title}"  # 編集
  end

  test "should get about" do
    get static_pages_about_url
    assert_response :success
    assert_select "title", "About | #{@base_title}"  # 編集
  end
end
```
+ `$ rails test`を実行<br>

```:terminal
[+] Running 1/0
 ⠿ Container rails-db  Running                                                                                                                                                                                0.0s
Running via Spring preloader in process 17
Started with run options --seed 37420

  3/3: [======================================================================================================================================================================] 100% Time: 00:00:01, Time: 00:00:01

Finished in 1.27139s
3 tests, 6 assertions, 0 failures, 0 errors, 0 skips
```

+ `app/views/static_pages/home.html.erb`<br>

```erb:home.html.erb
<% provide(:title, "Home") %>
<!DOCTYPE html>
<html>

<head>
  <title><%= yield(:title) %> | Ruby on Rails Tutorial Sample App</title>
</head>

<body>
  <h1>Sample App</h1>
  <p>
    This is the home page for the
    <a href="https://railstutorial.jp/">Ruby on Rails Tutorial</a>
    Sample application.
  </p>
</body>

</html>
```

+ `$ rails test`を実行<br>

```:terminal
[+] Running 1/0
 ⠿ Container rails-db  Running                                                                                                                                                                                0.0s
Running via Spring preloader in process 17
Started with run options --seed 14261

  3/3: [======================================================================================================================================================================] 100% Time: 00:00:02, Time: 00:00:02

Finished in 2.16612s
3 tests, 6 assertions, 0 failures, 0 errors, 0 skips
```

+ `app/views/static_pages/help.html.erb`を編集<br>

```erb:help.html.erb
<% provide(:title, "Help") %>
<!DOCTYPE html>
<html>

<head>
  <title><%= yield(:title) %> | Ruby on Rails Tutorial Sample App</title>
</head>

<body>
  <h1>Help</h1>
  <p>
    Get help on the Ruby on Rails Tutorial at the
    <a href="https://railstutorial.jp/help">Rails Tutorial help page</a>.
    To get help on this sample app, see the
    <a href="https://railstutorial.jp/#ebook"><em>Ruby on Rails Tutorial</em>
      book</a>.
  </p>
</body>

</html>
```

+ `$ rails test`を実行<br>

```:terminal
[+] Running 1/0
 ⠿ Container rails-db  Running                                                                                                                                                                                0.0s
Running via Spring preloader in process 18
Started with run options --seed 20977

  3/3: [======================================================================================================================================================================] 100% Time: 00:00:01, Time: 00:00:01

Finished in 1.34952s
3 tests, 6 assertions, 0 failures, 0 errors, 0 skips
```

+ `app/views/static_pages/about.html.erb`を実行<br>

```erb:abut.html.erb
<% provide(:title, "About") %>
<!DOCTYPE html>
<html>

<head>
  <title><%= yield(:title) %> | Ruby on Rails Tutorial Sample App</title>
</head>

<body>
  <h1>About</h1>
  <p>
    <a href="https://railstutorial.jp/">Ruby on Rails Tutorial</a>
    is a <a href="https://railstutorial.jp/#ebook">book</a> and
    to teach web development with
    <a href="https://rubyonrails.org/">Ruby on Rails</a>.
    This is the sample application for the tutorial.
  </p>
</body>

</html>
```

+ `$ rails test`を実行<br>

```:terminal
[+] Running 1/0
 ⠿ Container rails-db  Running                                                                                                                                                                                0.0s
Running via Spring preloader in process 16
Started with run options --seed 1662

  3/3: [======================================================================================================================================================================] 100% Time: 00:00:01, Time: 00:00:01

Finished in 1.72952s
3 tests, 6 assertions, 0 failures, 0 errors, 0 skips
```

+ `$ mv layout_file app/views/layouts/application.html.erb`を実行<br>

+ `app/views/layouts/application.html.erb`を編集<br>

```erb:application.html.erb
<!DOCTYPE html>
<html>
  <head>
    <!-- 編集 -->
    <title><%= yield(:title) %> | Ruby on Rails Tutorial Sample App</title>
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

+ `app/views/static_pages/home.html.erb`を編集<br>

```erb:home.html.erb
<% provide(:title, "Home") %>
<h1>Sample App</h1>
<p>
  This is the home page for the
  <a href="https://railstutorial.jp/">Ruby on Rails Tutorial</a>
  Sample application.
</p>
```

+ `app/views/static_pages/help.html.erb`を編集<br>

```erb:help.html.erb
<% provide(:title, "Help") %>
<h1>Help</h1>
<p>
  Get help on the Ruby on Rails Tutorial at the
  <a href="https://railstutorial.jp/help">Rails Tutorial help page</a>.
  To get help on this sample app, see the
  <a href="https://railstutorial.jp/#ebook"><em>Ruby on Rails Tutorial</em>
    book</a>.
</p>
```

+ `app/views/static_pages/about.html.erb`を編集<br>

```erb:about.html.erb
<% provide(:title, "About") %>
<h1>About</h1>
<p>
  <a href="https://railstutorial.jp/">Ruby on Rails Tutorial</a>
  is a <a href="https://railstutorial.jp/#ebook">book</a> and
  to teach web development with
  <a href="https://rubyonrails.org/">Ruby on Rails</a>.
  This is the sample application for the tutorial.
</p>
```

+ `$ rails test`を実行<br>

```:terminal
[+] Running 1/0
 ⠿ Container rails-db  Running                                                                                                                                                                                0.0s
Running via Spring preloader in process 17
Started with run options --seed 15067

  3/3: [======================================================================================================================================================================] 100% Time: 00:00:02, Time: 00:00:02

Finished in 2.64964s
3 tests, 6 assertions, 0 failures, 0 errors, 0 skips
```

## 3.4.4 ルーティングの設定

+ `config/routes.rb`を編集<br>

```rb:routes.rb
Rails.application.routes.draw do
  root 'static_pages#home' # 編集
  get 'static_pages/home'
  get 'static_pages/help'
  get 'static_pages/about'
end
```
