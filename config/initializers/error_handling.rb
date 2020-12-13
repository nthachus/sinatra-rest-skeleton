# frozen_string_literal: true

require 'sinatra/json'

module Skeleton
  # Error handling
  class Application < Sinatra::Base
    disable :show_exceptions, :raise_errors

    not_found do
      json_error I18n.t('app.resource_not_found')
    end

    error do
      e = env['sinatra.error']
      json_error I18n.t('app.something_went_wrong'), settings.production? ? e.to_s : StackTraceArray.new(e)
    end

    helpers do
      # @param [String] message
      def json_error(message, extra = nil)
        json extra.present? ? { error: message, extra: extra } : { error: message }
      end

      # Halt processing and return a 501 Not Implemented.
      def not_implemented(body = nil)
        error 501, body || json_error(I18n.t('app.function_not_implemented'))
      end
    end
  end
end
