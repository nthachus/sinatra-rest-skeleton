# frozen_string_literal: true

require 'sinatra/reloader'

module Skeleton
  # To reload modified files during development
  class Application < Sinatra::Base
    # :nocov:
    configure :development do
      register Sinatra::Reloader

      also_reload File.expand_path('../../app/**/*.rb', __dir__)
      dont_reload File.expand_path('../../vendor/**', __dir__)
    end
    # :nocov:
  end
end
