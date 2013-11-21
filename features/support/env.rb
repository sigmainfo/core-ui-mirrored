# encoding: utf-8

ENV["RAILS_ENV"] = "test"
require File.expand_path(File.join("..", "..", "config", "environment"), File.dirname(__FILE__))

require 'spinach/capybara'
require "net/http"
require "./features/support/core-api"

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

Capybara.default_driver = :chrome
Capybara.default_wait_time = 2
Capybara.server_port = 4000

Capybara.register_driver :firefox do |app|
  Capybara::Selenium::Driver.new(app, :browser => :firefox)
end

Spinach.hooks.on_tag('firefox') do
  ::Capybara.current_driver = ::Capybara.javascript_driver = :selenium
end

Spinach.hooks.before_scenario do
  CoreAPI.purge!
  CoreClient::Auth.purge!
  CoreClient::Auth.register_api_key

  # start server
  Capybara.current_session.visit "/"

  # disable jQuery animations
  Capybara.current_session.execute_script "jQuery.fx.off = true"
  Capybara.current_session.execute_script "localStorage.clear()"
end

# Spinach.config.save_and_open_page_on_failure = true
