require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Lodgistics
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/lib)
    config.enable_dependency_loading = true
    config.autoload_paths += Dir["#{config.root}/lib", "#{config.root}/lib/extensions", "#{config.root}/app/workers/*"]

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    #config.active_record.schema_format = :sql

    # Enable the asset pipeline
    config.assets.enabled = true

    # Devise
    config.assets.initialize_on_precompile = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.assets.paths << Rails.root.join("app", "assets", "files")
    config.assets.paths << Rails.root.join('vendor', 'assets', 'theme')

    config.exceptions_app = self.routes

    # Factory Girl Rails
    config.generators do |generator|
      generator.fixture_replacement :factory_girl
    end

    # MiniTest
    config.generators do |g|
      g.test_framework :mini_test, fixture: false
    end

    config.to_prepare {
      Devise::Mailer.layout 'mail'
    }

    Rabl.configure do |config|
      config.include_json_root = false
      config.include_child_root = false
    end
  end
end
