# frozen_string_literal: true

module Skeleton
  # Makes JSON-encoded request bodies available in the @params hash.
  class Application < Sinatra::Base
    before do
      if %w[POST PATCH PUT].include?(request.request_method) && request.media_type == mime_type(settings.json_content_type) &&
         (body_content = request.body.read) && !body_content.empty?

        request.body.rewind # somebody might try to read this stream
        begin
          @params.merge! settings.json_encoder.decode(body_content)
        rescue StandardError => e # JSON error
          logger.warn e.stacktrace(0)
          bad_request json_error(I18n.t('app.bad_json_request'), settings.production? ? nil : e.to_s)
        end
      end
    end

    helpers do
      # Halt processing and return a 400 Bad Request.
      def bad_request(body = nil)
        error 400, body
      end
    end
  end
end
