# frozen_string_literal: true

require 'sinatra/config_file'

module Skeleton
  # Load application settings
  class Application < Sinatra::Base
    register Sinatra::ConfigFile

    config_file File.expand_path('../settings.yml', __dir__)
  end
end
