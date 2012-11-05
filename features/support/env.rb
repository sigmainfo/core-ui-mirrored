# encoding: utf-8

ENV["RAILS_ENV"] = "test"
require File.expand_path(File.join("..", "..", "config", "environment"), File.dirname(__FILE__))

require "rspec"
require "net/http"
require "./features/support/core-api"
  
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end
Capybara.default_driver = :selenium
# Capybara.default_wait_time = 5
Capybara.server_port = 4000

Spinach.hooks.before_scenario do
  #Mongoid.purge!
  CoreAPI.purge! 

  # start server
  include Capybara::DSL
  visit "/"

  # Purge Users
  uri = URI.parse(CoreClient::Auth.url_for "users/purge")
  http = Net::HTTP.new(uri.host, uri.port)
  begin
    response = http.get(
      uri.request_uri,
      { 
        "Content-Type" => "application/json; charset=utf-8",
        "Accept" => "application/json"
      }
    )
  rescue
    unless Rails.env.test?
      cmd = Rails.root.join '..', 'core-shell', 'script', 'test-servers'
      puts "  \033[31m✘\n  ✘ Auth service not available at #{uri} - did you start the server by running:\n  ✘\033[0m\n\n    #{cmd} start\n\n  \033[33m✘\n  ✘ If you did so, try to update your core-auth repository and restart the server with:\n  ✘\033[0m\n\n    #{cmd} stop\n    #{cmd} start\n\n"
    end
    raise "Auth service not available"
  end

  # disable jQuery animations
  page.execute_script "jQuery.fx.off = true"
end
#
# Spinach.config.save_and_open_page_on_failure = true
