Capybara.server do |app, port|
  require 'rack/handler/thin'
  Rack::Handler::Thin.run(app, :Port => port)
end if defined?(Capybara)

Konacha.configure do |config|
  require 'capybara/poltergeist'
  config.spec_dir  = "spec"
  config.driver    = :poltergeist
end if defined?(Konacha)
