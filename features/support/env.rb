# encoding: utf-8

ENV["RAILS_ENV"] = "test"
require File.expand_path(File.join("..", "..", "config", "environment"), File.dirname(__FILE__))

# require "rspec"
require "net/http"
require "./features/support/core-api"
  
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end
Capybara.default_driver = :selenium
Capybara.default_wait_time = 2
Capybara.server_port = 4000

Spinach.hooks.before_scenario do
  #Mongoid.purge!
  CoreAPI.purge! 
  CoreClient::Auth.purge!
  CoreClient::Auth.register_api_key

  # start server
  # include Capybara::DSL
  Capybara.current_session.visit "/"
  
  # disable jQuery animations
  Capybara.current_session.execute_script "jQuery.fx.off = true"
  Capybara.current_session.driver.browser.manage.window.resize_to(1800, 1000)
end
#
# Spinach.config.save_and_open_page_on_failure = true

