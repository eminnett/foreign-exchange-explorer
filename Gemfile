# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.1'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use Elasticsearch for data storage
gem 'elasticsearch', '~> 6.1'
gem 'elasticsearch-model', '~> 6.0'
gem 'elasticsearch-persistence', '~> 6.0'
gem 'elasticsearch-rails', '~> 6.0'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Use Sidekiq for delayed jobs
gem 'sidekiq', '~> 5.2'
gem 'sidekiq-client-cli', '~> 0.1.7'

# Use Whenever to manage cron jobs
gem 'whenever', '~> 0.10.0'

# Use HTTParty for request external resources
gem 'httparty', '~> 0.16.3'

# Client-side dependencies
gem 'webpacker', '~> 3.5'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '~> 4.1'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]

  # Ensure bundled gems pass the bundler audit
  gem 'bundler-audit', '~> 0.5.0'

  gem 'rubocop', '~> 0.60.0'

  gem 'rspec-rails', '~> 3.8'

  gem "rspec_junit_formatter", "~> 0.4.1"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'

  gem 'shoulda-matchers', '~> 3.1'

  gem "simplecov", "~> 0.16.1"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'react-rails', '~> 2.4'
