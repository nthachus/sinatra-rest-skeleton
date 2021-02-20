# frozen_string_literal: true

module Skeleton
  # Disables client caching.
  class Application < Sinatra::Base
    after do
      # && response.successful?
      response.do_not_cache! if !response.cache_control && response.media_type == mime_type(settings.json_content_type)
    end
  end
end
