# frozen_string_literal: true

require_relative 'boot'
require 'i18n'
require 'sinatra/activerecord'
require 'sinatra/config_file'

module Skeleton
  # Base API Controller
  class Application < Sinatra::Base
    # Global settings
    set :root, File.expand_path('..', __dir__)
    disable :static
    enable :method_override, :dump_errors

    # Load application settings
    register Sinatra::ConfigFile
    config_file File.expand_path('settings.yml', __dir__)

    # Localization
    configure do
      I18n.backend.extend I18n::Backend::Fallbacks
      I18n.load_path << Dir[File.expand_path('locales/**/*.yml', __dir__)]
      # I18n.default_locale = :ja
      I18n.fallbacks.defaults = [I18n.default_locale]
    end

    configure :development, :test do
      # Logging with DEBUG level
      set :logging, 0
    end

    configure :production do
      # :nocov:
      set :logging, nil
      use Rack::Logger
      # :nocov:
    end

    # Setup the database
    register Sinatra::ActiveRecordExtension

    # Response JSON with the default charset
    # noinspection RubyResolve
    settings.add_charset << %r{/json$}
  end
end

Dir[File.expand_path('../app/{helpers,models}/*.rb', __dir__)].sort.each(&method(:require))
