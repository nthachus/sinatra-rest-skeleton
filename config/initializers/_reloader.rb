# frozen_string_literal: true

require 'sinatra/reloader'

module Skeleton
  class Application < Sinatra::Base
    # To reload modified files during development
    configure :development do
      register Sinatra::Reloader

      also_reload File.expand_path('../../app/**/*.rb', __dir__)
      dont_reload File.expand_path('../../vendor/**', __dir__)
    end
  end
end
