source "https://rubygems.org"

gem "rails", "~> 3.2"

# Bundle edge Rails instead:
# gem "rails", :git => "git://github.com/rails/rails.git"

gem "core_client", git: "git@devel.spom.net:core-client.git"
gem "mongoid", "~> 3.0.0"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem "sass-rails",   "~> 3.2.3"
  gem "coffee-rails", "~> 3.2.1"
  gem "therubyracer", platforms: :ruby
  gem "uglifier", ">= 1.0.3"

  gem "haml_coffee_assets"
  gem "execjs"
  gem "i18n-js"
end

gem "jquery-rails"

# To use ActiveModel has_secure_password
gem "bcrypt-ruby", "~> 3.0.0"

# To use Jbuilder templates for JSON
# gem "jbuilder"

# Use unicorn as the app server
# gem "unicorn"

# Deploy with Capistrano
# gem "capistrano"

# To use debugger
# gem "debugger"

group :development do
  gem "thin"
  gem "konacha"
end

group :test do
  gem "spinach-rails"
end

group :test, :development do
  gem "capybara-webkit"
  gem "rspec-rails", require: false
end
