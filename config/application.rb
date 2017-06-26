require_relative 'boot'

require 'rails/all'
Bundler.require(*Rails.groups)

module ChemPricing
  class Application < Rails::Application
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*',
          headers: :any,
          expose: ['X-Page', 'X-PageTotal'],
          methods: [:get, :post, :delete, :put, :options]
      end
    end
    config.i18n.default_locale = 'pt-BR'
    config.i18n.fallbacks = [:es, :en]

    config.assets.paths << Rails.root.join('node_modules')
    config.load_defaults 5.1
    config.time_zone = 'Brasilia'
    config.active_record.default_timezone = :utc
    config.action_mailer.default_url_options = { host:  ENV['APPLICATION_HOST'] }
  end
end
