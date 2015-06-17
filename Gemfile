source "https://rubygems.org"

if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

gem 'rails', '4.2.2'

if false
  gem 'core_client', path: '../core-client'
else
  gem 'core_client', git: 'git@github.com:gmah/core-client.git'
end

# gem 'turbolinks'
# gem 'jbuilder', '~> 2.0'

gem 'compass-rails'
gem 'sass-rails', '~> 5.0'
gem 'haml_coffee_assets'
gem 'i18n-js'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', '~> 4.1.0'
  gem 'therubyracer', platforms: :ruby
  gem 'uglifier', '>= 1.3.0'
  gem 'execjs'
end

gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 4.1'

gem 'rack-cors', require: 'rack/cors'
gem 'rest-client'

group :development do
  gem 'thin'
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
end

group :test do
  gem 'poltergeist', '~> 1.6.0'
  gem 'rspec', '~> 2.13.0'
  gem 'spinach-rails'
  gem 'selenium-webdriver', '~> 2.45'
  gem 'launchy'
end

group :test, :development do
  gem 'awesome_print'
  gem 'colorize'
  gem 'konacha'
  gem 'capybara-webkit'
  gem 'rspec-rails', require: false
  gem 'pry'
  gem 'pry-theme'
  gem 'pry-rails'
  # gem 'byebug'
  gem 'web-console', '~> 2.0'
end
