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
