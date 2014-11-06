if defined?(Capybara)
  Capybara.server do |app, port|
    require 'rack/handler/thin'
    Rack::Handler::Thin.run(app, :Port => port)
  end

  Capybara.register_driver :slow_poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, :timeout => 60)
  end
end

Konacha.configure do |config|
  require 'capybara/poltergeist'
  config.spec_dir  = "spec"
  config.driver    = :slow_poltergeist
end if defined?(Konacha)
