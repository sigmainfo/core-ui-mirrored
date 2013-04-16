source "https://rubygems.org"

if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

gem "rails", "= 3.2.12" # Needed for i18n-js with ruby 1.9

# Bundle edge Rails instead:
# gem "rails", :git => "git://github.com/rails/rails.git"

gem "core_client", git: "git@devel.spom.net:core-client.git"
gem "mongoid", "~> 3.0.0"

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

gem "bcrypt-ruby", "~> 3.0.0"
gem "rack-cors", require: "rack/cors"

group :development do
  gem "thin"
  gem "konacha", "~> 2.3.0"
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
  gem "capybara-webkit", "~>0.14.2"
  gem "rspec-rails", require: false
  gem "text"
  gem "pry"
end
