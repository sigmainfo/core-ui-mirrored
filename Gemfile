source "https://rubygems.org"

if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

gem 'rails', '= 3.2.12' # Needed for i18n-js with ruby 1.9
if false
  gem 'core_client', path: '../core-client'
else
  gem 'core_client', git: 'git@github.com:gmah/core-client.git'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'compass-rails'
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'therubyracer', platforms: :ruby
  gem 'uglifier', '>= 1.0.3'

  gem 'haml_coffee_assets'
  gem 'execjs'
  gem 'i18n-js'
end

gem 'jquery-rails'
gem 'jquery-ui-rails'

gem 'rack-cors', require: 'rack/cors'
gem 'rest-client'

group :development do
  gem 'thin'
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
end

group :test do
  gem 'poltergeist', '~> 1.5.1'
  gem 'rspec', '~> 2.13.0'
  gem 'spinach-rails'
  gem 'selenium-webdriver', '~> 2.43.0'
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
end
