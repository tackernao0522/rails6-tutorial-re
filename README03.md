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
