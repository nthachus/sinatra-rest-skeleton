# frozen_string_literal: true

require 'rack/contrib/locale'

module Skeleton
  # Localization with Accept-Language header
  class Application < Sinatra::Base
    use Rack::Locale
  end
end
