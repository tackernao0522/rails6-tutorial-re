## Dokcer 参考 URL

https://qiita.com/maru401/items/2f5815c40fcf6d2d80d6#web-process-failed-to-bind-to-port-within-60-seconds-of-launch<br>

+ 開発環境は localhost:3200 でアクセス<br>

## 本番環境への動作確認

- `$ touch docker-compose.prod.yml`を実行<br>

- `docker-compose.prod.yml`を編集<br>

```yml:docker-compose.prod.yml
version: '3.5'
services:
  web:
    build: .
    container_name: rails-web
    command: bash -c "rm -f tmp/pids/server.pid && bundle exec rails s -p 3000 -b '0.0.0.0'"
    volumes:
      - .:/app
      - /var/tmp
    environment:
      RAILS_ENV: production
      RAILS_SERVE_STATIC_FILES: 1
    ports:
      - 3000:3000
    depends_on:
      - db
    tty: true
    stdin_open: true
    networks:
      - sample

  db:
    image: postgres:9.6.2-alpine
    container_name: rails-db
    environment:
      POSTGRES_PASSWORD: 12345678
      TZ: "Asia/Tokyo"
    volumes:
      - pg-data:/var/lib/postgresql/data
    restart: always
    ports:
      - 5432:5432
    networks:
      - sample

networks:
  sample:

volumes:
  pg-data:
```

+ `$ docker compose build`を実行<br>

+ `$ `config/procution.rb`を編集<br>

```rb:production.rb
require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = true # 編集

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = true # 編集

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Mount Action Cable outside main process or domain.
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Include generic and useful information about system operation, but avoid logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII).
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "app_production"

  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Log disallowed deprecations.
  config.active_support.disallowed_deprecation = :log

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require "syslog/logger"
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Inserts middleware to perform automatic connection switching.
  # The `database_selector` hash is used to pass options to the DatabaseSelector
  # middleware. The `delay` is used to determine how long to wait after a write
  # to send a subsequent read to the primary.
  #
  # The `database_resolver` class is used by the middleware to determine which
  # database is appropriate to use based on the time delay.
  #
  # The `database_resolver_context` class is used by the middleware to set
  # timestamps for the last write to the primary. The resolver uses the context
  # class timestamps to determine how long to wait before reading from the
  # replica.
  #
  # By default Rails will store a last write timestamp in the session. The
  # DatabaseSelector middleware is designed as such you can define your own
  # strategy for connection switching and pass that into the middleware through
  # these configuration options.
  # config.active_record.database_selector = { delay: 2.seconds }
  # config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  # config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session
end
```

+ `$ docker-compose -f docker-compose.prod.yml up -d`を実行<br>

+ `$ docker compose exec web bash`を実行<br>

+ `app# bin/rails assets:precompile RAILS_ENV=production`を実行<br>

+ `app# rails db:create`を実行<br>

+ `app# rails db:migrate`を実行<br>

+ `$ docker compose -f docker-compose.prod.yml up`でproduction serverを起動できる localhost:3000 になる`<br>

## herokuへのデプロイ

+ `$ heroku login`を実行<br>

+ `$ heroku container:login`を実行<br>

+ `$ heroku create 付けたいアプリ名`を実行<br>

+ $ docker-compose run --rm web rails assets:precompile RAILS_ENV=production`を実行<br>

+ `Dockerfile`を編集<br>

```:Dockerfile
FROM ruby:2.6.5

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && apt-get update && \
    apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

RUN apt-get update && apt-get install -y curl apt-transport-https wget && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn

RUN apt-get update -qq && \
    apt-get install -y build-essential \
    libpq-dev \
    sudo  \
    vim

RUN yarn add node-sass

WORKDIR /app
RUN mkdir -p tmp/sockets
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install
COPY . /app

# COPY entrypoint.sh /usr/bin/
# RUN chmod +x /usr/bin/entrypoint.sh
# ENTRYPOINT ["entrypoint.sh"]

# 以下の記述を追加
ENV RAILS_ENV=production

# この記述を追加
CMD bash -c "rm -f tmp/pids/server.pid && bundle exec puma -C config/puma.rb"
```

+ `database.yml`を編集<br>

```yml:database.yml
production:
  <<: *default
  database: app_production
  username: <%= ENV['DB_USERNAME'] || 'postgres' %>
  host: <%= ENV['DB_HOST'] || 'db' %>
  password: <%= ENV['DB_PASSWORD'] || '12345678' %>
  url: <%= ENV['DATABASE_URL'] %>

  # または(いずれかで動作)
  production:
  <<: *default
  database: app_production
  username: <%= ENV['DB_USERNAME'] || 'postgres' %>
  host: <%= ENV['DB_HOST'] || 'db' %>
  password: <%= ENV['DB_PASSWORD'] || '12345678' %>
  url: <%= ENV['DATABASE_URL'] %>
```
+ `$ heroku addons:create heroku-postgresql:hobby-dev`を実行<br>

+ $ `heroku container:push web`を実行<br>

+ `$ heroku container:release web`を実行<br>

+ `$ heroku run rails db:migrate`を実行<br>

+ `$ heroku run rails assets:precompile`を実行<br>

+ `$ heroku open`でアクセスできる<br>

## 3.2.1 静的なページの作成

+ `$ rails g controller StaticPages home help`を実行<br>

## 3.8 StaticPagesコントローラ内の`home`アクションと`help`アクションで使うルーティング

+ `app/controllers/ApplicactionController.rb`を編集<br>

```rb:ApplicactionController.rb
class ApplicationController < ActionController::Base
  def hello
    render html: "hello, world!"
  end
end
```

+ `config/routes.rb`を編集<br>

```rb:routes.rb
Rails.application.routes.draw do
  get 'static_pages/home'
  get 'static_pages/help'
  root 'application#hello'
end
```

## 3.2.2 静的なページの調整

+ `app/views/static_pages/home.html.erb`を編集<br>

```erb:home.html.erb
<h1>Sample App</h1>
<p>
  This is the home page for the
  <a href="https://railstutorial.jp/">Ruby on Rails Tutorial</a>
  Sample application.
</p>
```

+ `app/views/static_pages/help.html.erb`を編集<br>

```erb:help.html.erb
<h1>Help</h1>
<p>
  Get help on the Ruby on Rails Tutorial at the
  <a href="https://railstutorial.jp/help">Rails Tutorial help page</a>.
  To get help on this sample app, see the
  <a href="https://railstutorial.jp/#ebook"><em>Ruby on Rails Tutorial</em>
    book</a>.
</p>
```

## 3.3.1 最初のテスト

+ `$ rails db:migrate` (システムによっては必要)<br>

+ `$ rails test`を実行<br>

```:terminal
[+] Running 1/0
 ⠿ Container rails-db  Running                                                                                                                                                                                0.0s
Running via Spring preloader in process 18
Running via Spring preloader in process 23
Run options: --seed 14411

# Running:

..

Finished in 49.939128s, 0.0400 runs/s, 0.0400 assertions/s.
2 runs, 2 assertions, 0 failures, 0 errors, 0 skips
```

+ `test/controllers/static_pages_controller_test.rb`を編集<br>

```rb:static_pages_controller_test.rb
require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get static_pages_home_url
    assert_response :success
  end

  test "should get help" do
    get static_pages_help_url
    assert_response :success
  end

  test "should get about" do
    get static_pages_about_url
    assert_response :success
  end
end
```

+ `$ rails text`を実行<br>

```:terminal
[+] Running 1/0
 ⠿ Container rails-db  Running                                                                                                                                                                                0.0s
Running via Spring preloader in process 18
Run options: --seed 141

# Running:

..E

Error:
StaticPagesControllerTest#test_should_get_about:
NameError: undefined local variable or method `static_pages_about_url' for #<StaticPagesControllerTest:0x00005598cd30bd10>
    test/controllers/static_pages_controller_test.rb:15:in `block in <class:StaticPagesControllerTest>'


rails test test/controllers/static_pages_controller_test.rb:14



Finished in 4.874772s, 0.6154 runs/s, 0.4103 assertions/s.
3 runs, 2 assertions, 0 failures, 1 errors, 0 skips
```

+ `config/routes.rb`を編集<br>

```rb:routes.rb
Rails.application.routes.draw do
  get 'static_pages/home'
  get 'static_pages/help'
  get 'static_pages/about'
  root 'application#hello'
end
```

+ `rails test`を実行<br>

```:terminal
[+] Running 1/0
 ⠿ Container rails-db  Running                                                                                                                                                                                0.0s
Running via Spring preloader in process 17
Run options: --seed 62723

# Running:

E

Error:
StaticPagesControllerTest#test_should_get_about:
RuntimeError: Wrapped undumpable exception for: AbstractController::ActionNotFound: The action 'about' could not be found for StaticPagesController
    test/controllers/static_pages_controller_test.rb:15:in `block in <class:StaticPagesControllerTest>'


rails test test/controllers/static_pages_controller_test.rb:14

..

Finished in 8.492840s, 0.3532 runs/s, 0.2355 assertions/s.
3 runs, 2 assertions, 0 failures, 1 errors, 0 skips
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
end
```

+ `$ rails test`を実行<br>

```:terminal
[+] Running 1/0
 ⠿ Container rails-db  Running                                                                                                                                                                                0.0s
Running via Spring preloader in process 16
Run options: --seed 24194

# Running:

E

Error:
StaticPagesControllerTest#test_should_get_about:
ActionController::MissingExactTemplate: StaticPagesController#about is missing a template for request formats: text/html
    test/controllers/static_pages_controller_test.rb:15:in `block in <class:StaticPagesControllerTest>'


rails test test/controllers/static_pages_controller_test.rb:14

..

Finished in 2.425876s, 1.2367 runs/s, 0.8244 assertions/s.
3 runs, 2 assertions, 0 failures, 1 errors, 0 skips
```

+ `$ touch app/views/static_pages/about.html.erb`を実行<br>

+ `app/views/static_pages/about.html.erb`を編集<br>

```erb:about.html.erb
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
 ⠿ Container rails-db  Running                                                                                                                                                                                0.0s
Running via Spring preloader in process 16
Run options: --seed 21258

# Running:

...

Finished in 2.458235s, 1.2204 runs/s, 1.2204 assertions/s.
3 runs, 3 assertions, 0 failures, 0 errors, 0 skips
```
