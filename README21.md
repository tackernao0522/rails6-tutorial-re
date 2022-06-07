## RSpecとFactoryBotの導入

https://zenn.dev/fu_ga/books/ff025eaf9eb387/viewer/372a93 <br>

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
gem 'aws-sdk-s3',              '1.48.0', require: false
gem 'image_processing',           '1.9.3'
gem 'mini_magick',                '4.9.5'
gem 'active_storage_validations', '0.8.2'
# Use Active Model has_secure_password
gem 'bcrypt', '~> 3.1.7'
gem 'faker', '2.20.0'
gem 'will_paginate', '3.3.1'
gem 'bootstrap-will_paginate', '1.0.0'

# コンソールの出力結果を見やすく表示する
gem 'hirb', '~> 0.7.3'

# Hirbの文字列補正を行う
gem 'hirb-unicode-steakknife', '~> 0.0.9'

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
  gem 'rspec-rails' # 追加
  gem 'factory_bot_rails' # 追加
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
```

+ `$ bundle install`を実行<br>

+ `$ bin/rails g rspec:install`を実行<br>

+ `.rspec`を編集<br>

```:.rspec
--require spec_helper
--format documentation # 追加
```

+ `$ bundle exec rspec`を実行<br>

```:terminal
[+] Running 1/0
 ⠿ Container rails-db  Running                                                                                                                                                                                  0.0s
No examples found.

Finished in 0.00228 seconds (files took 0.24496 seconds to load)
0 examples, 0 failures
```

+ `config/application.rb`を編集<br>

```rb:application.rb
require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # 認証トークンをremoteフォームに埋め込む
    config.action_view.embed_authenticity_token_in_remote_forms = true

    # 追加
    config.generators do |g|
      g.test_framework :rspec,
        view_specs: false,
        helper_specs: false,
        routing_specs: false
    end
    # ここまで
  end
end
```

+ `$ rails g rspec:request static_pages`を実行<br>

+ `spec/requests/static_pages_spec.rb`を編集<br>

```rb:static_pages_spec.rb
require 'rails_helper'

RSpec.describe 'StaticPages', type: :request do
  describe '#home' do
    it '正常にレスポンスを返すこと' do
      get root_path
      expect(response).to have_http_status :ok
    end
  end

  describe '#help' do
    it '正常にレスポンスを返すこと' do
      get help_path
      expect(response).to have_http_status :ok
    end
  end

  describe '#about' do
    it '正常にレスポンスを返すこと' do
      get about_path
      expect(response).to have_http_status :ok
    end
  end
end
```

+ `$ bundle exec rspec spec/requests/static_pages_spec.rb`を実行<br>

```:terminal
[+] Running 1/0
 ⠿ Container rails-db  Running                                                                                                                                                                                  0.0s

StaticPages
  #home
    正常にレスポンスを返すこと
  #help
    正常にレスポンスを返すこと
  #about
    正常にレスポンスを返すこと

Finished in 0.46167 seconds (files took 7.72 seconds to load)
3 examples, 0 failures
```

+ `RSpecコマンドの実行例`<br>

```:terminal
# 全てのテスト実行する
$ bundle exec rspec

# 特定の種類のテストを実行する
$ bundle exec rspec spec/requests
$ bundle exec rspec spec/system

# 特定のファイルのテストを実行する
$ bundle exec rspec spec/requests/static_pages_spec.rb

# 特定のファイルの特定の行からテストを実行する
$ bundle exec rspec spec/requests/static_pages_spec.rb:20
```

+ `spec/requests/static_pages_spec.rb`を編集<br>

```rb:static_pages_spec.rb
require 'rails_helper'

RSpec.describe 'StaticPages', type: :request do
  let(:base_title) { 'Ruby on Rails Tutorial Sample App' } # 追加

  describe '#home' do
    it '正常にレスポンスを返すこと' do
      get root_path
      expect(response).to have_http_status :ok
    end
    # 追加
    it 'Ruby on Rails Tutorial Sample Appが含まれること' do
      get root_path
      expect(response.body).to include "#{base_title}"
    end
    # ここまで
  end

  describe '#help' do
    it '正常にレスポンスを返すこと' do
      get help_path
      expect(response).to have_http_status :ok
    end
    # 追加
    it 'Help | Ruby on Rails Tutorial Sample Appが含まれること' do
      get help_path
      expect(response.body).to include "Help | #{base_title}"
    end
    # ここまで
  end

  describe '#about' do
    it '正常にレスポンスを返すこと' do
      get about_path
      expect(response).to have_http_status :ok
    end
    # 追加
    it 'About | Ruby on Rails Tutorial Sample Appが含まれること' do
      get about_path
      expect(response.body).to include "About | #{base_title}"
    end
    # ここまで
  end
end
```

## 3.4.3: 演習

+ `spec/requests/static_pages_spec.rb`を編集<br>

```rb:static_pages_spec.rb
require 'rails_helper'

RSpec.describe 'StaticPages', type: :request do
  let(:base_title) { 'Ruby on Rails Tutorial Sample App' }

  describe 'root' do # 編集
    it '正常にレスポンスを返すこと' do
      get root_path
      expect(response).to have_http_status :ok
    end
    it 'Ruby on Rails Tutorial Sample Appが含まれること' do
      get root_path
      expect(response.body).to include "#{base_title}"
    end
  end

  describe '#help' do
    it '正常にレスポンスを返すこと' do
      get help_path
      expect(response).to have_http_status :ok
    end

    it 'Help | Ruby on Rails Tutorial Sample Appが含まれること' do
      get help_path
      expect(response.body).to include "Help | #{base_title}"
    end
  end

  describe '#about' do
    it '正常にレスポンスを返すこと' do
      get about_path
      expect(response).to have_http_status :ok
    end

    it 'About | Ruby on Rails Tutorial Sample Appが含まれること' do
      get about_path
      expect(response.body).to include "About | #{base_title}"
    end
  end

  # 追加
  describe '#contact' do
    it '正常にレスポンスを返すこと' do
      get contact_path
      expect(response).to have_http_status :ok
    end

    it 'Contact | Ruby on Rails Tutorial Sample Appが含まれること' do
      get contact_path
      expect(response.body).to include "Contact | #{base_title}"
    end
  end
  # ここまで
end
```
# コード例 第4章

# リスト: 4.4

+ `spec/requests/static_pages_spec.rb`を編集<br>

```rb:static_pages_spec.rb
require 'rails_helper'

RSpec.describe 'StaticPages', type: :request do
  let(:base_title) { 'Ruby on Rails Tutorial Sample App' }

  describe 'root' do
    it '正常にレスポンスを返すこと' do
      get root_path
      expect(response).to have_http_status :ok
    end

    # 編集
    it 'titleがRuby on Rails Tutorial Sample Appであること' do
      get root_path
      expect(response.body).to include "<title>#{base_title}</title>"
    end
    # ここまで
  end

  describe '#help' do
    it '正常にレスポンスを返すこと' do
      get help_path
      expect(response).to have_http_status :ok
    end

    it 'Help | Ruby on Rails Tutorial Sample Appが含まれること' do
      get help_path
      expect(response.body).to include "Help | #{base_title}"
    end
  end

  describe '#about' do
    it '正常にレスポンスを返すこと' do
      get about_path
      expect(response).to have_http_status :ok
    end

    it 'About | Ruby on Rails Tutorial Sample Appが含まれること' do
      get about_path
      expect(response.body).to include "About | #{base_title}"
    end
  end

  describe '#contact' do
    it '正常にレスポンスを返すこと' do
      get contact_path
      expect(response).to have_http_status :ok
    end

    it 'Contact | Ruby on Rails Tutorial Sample Appが含まれること' do
      get contact_path
      expect(response.body).to include "Contact | #{base_title}"
    end
  end
end
```