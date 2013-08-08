Capybara.server do |app, port|
  require 'rack/handler/thin'
  Rack::Handler::Thin.run(app, :Port => port)
end if defined?(Capybara)

require 'capybara/poltergeist'

Konacha.configure do |config|
  config.spec_dir  = "spec"
  config.driver    = :poltergeist
end if defined?(Konacha)
