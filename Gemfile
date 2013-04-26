source "https://rubygems.org"

if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

gem "rails", "= 3.2.12" # Needed for i18n-js with ruby 1.9
gem "core_client", git: "git@devel.spom.net:core-client.git"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'compass-rails'
  gem "sass-rails",   "~> 3.2.3"
  gem "coffee-rails", "~> 3.2.1"
  gem "therubyracer", platforms: :ruby
  gem "uglifier", ">= 1.0.3"

  gem "haml_coffee_assets"
  gem "execjs"
  gem "i18n-js"
end

gem "jquery-rails"
gem "jquery-ui-rails"

gem "rack-cors", require: "rack/cors"

group :development do
  gem "konacha"
  gem 'capistrano'
  gem 'capistrano-ext'
end

group :test do
  gem "spinach-rails"
  gem "selenium-webdriver"
  gem "launchy"
  gem "rspec"
end

group :test, :development do
  gem "capybara-webkit"
  gem "rspec-rails", require: false
  gem "pry"
end
