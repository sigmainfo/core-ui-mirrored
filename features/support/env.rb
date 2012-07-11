ENV["RAILS_ENV"] = "test"
require File.expand_path(File.join("..", "..", "server", "config", "environment"), File.dirname(__FILE__))

require "rspec"

# require "database_cleaner"
# DatabaseCleaner.strategy = :truncation
#
# Spinach.hooks.before_scenario{ DatabaseCleaner.clean }
#
# Spinach.config.save_and_open_page_on_failure = true
