require File.expand_path('../boot', __FILE__)

if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

# Pick the frameworks you want:
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "active_resource/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
Bundler.require(*Rails.groups(:assets => %w(development styling test)))

module CoreUi
  class Application < Rails::Application
    # Adjust paths to map project structure
    paths["app"] = []
    paths["app"] << "server"
    #paths["app"].delete "app"

    %w|controllers helpers models mailers views|.each do |dir|
      paths["app/#{dir}"] << "server/#{dir}"
      #paths["app/#{dir}"].delete "app/#{dir}"
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # config.active_record.raise_in_transactional_callbacks = true

    # Add project directory to assets paths
    config.assets.paths << "app/config"
    config.assets.paths << "app"

    # Create multiple CSS files for theming
    config.assets.precompile += ['themes/berlin.css', 'themes/athens.css']

    # HAML assets
    if defined? ::HamlCoffeeAssets
      config.hamlcoffee.namespace = "window.Coreon.Templates"
    end

    config.assets.initialize_on_precompile = true
  end
end
