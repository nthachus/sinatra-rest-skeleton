# frozen_string_literal: true

require 'sinatra/json'

module Skeleton
  # Error handling
  class Application < Sinatra::Base
    disable :show_exceptions, :raise_errors

    not_found do
      json_error I18n.t('app.resource_not_found') unless content_type&.include? mime_type(settings.json_content_type)
    end

    error do
      e = env['sinatra.error']
      json_error I18n.t('app.something_went_wrong'), settings.production? ? e.to_s : e.stacktrace
    end

    helpers do
      # @param [String] message
      # @return [String]
      def json_error(message, details = nil)
        json details.present? ? { message: message, details: details } : { message: message }
      end

      # Halt processing and return a 501 Not Implemented.
      def not_implemented(body = nil)
        error 501, body || json_error(I18n.t('app.function_not_implemented'))
      end
    end
  end
end
