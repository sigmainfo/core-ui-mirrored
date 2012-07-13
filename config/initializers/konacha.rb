Konacha.configure do |config|
  config.spec_dir  = "spec"
  config.driver    = :webkit
end if defined?(Konacha)
