# frozen_string_literal: true

require 'rack/auth/abstract/request'

module Skeleton
  # Authentication and Authorization with JWT in Sinatra
  class Application < Sinatra::Base
    attr_reader :current_user
    set :authorization_method, ->(_jwt) {}

    before do
      if !request.options? && (req = Rack::Auth::AbstractRequest.new(env)).provided? && req.scheme == 'bearer'
        begin
          @current_user = settings.authorization_method.call req.params
        rescue JWT::ExpiredSignature => e
          logger.warn e
          unauthorized json_error(I18n.t('app.expired_token'), settings.production? ? nil : e.to_s)
        rescue JWT::DecodeError => e
          logger.error e
          unauthorized json_error(I18n.t('app.invalid_token'), settings.production? ? e.to_s : [e.inspect] + e.backtrace)
        end
      end
    end

    # A way to require authorization
    #
    #   get '/', authorize: [:admin] do
    #     ...
    #   end
    #
    set(:authorize) do |*roles|
      condition do
        # Make sure it's logged-in
        unauthorized json_error(I18n.t('app.missing_token')) unless current_user

        access_denied json_error(I18n.t('app.access_denied')) if
          roles.present? && current_user.respond_to?(:role) && !(current_user.role && roles.include?(current_user.role.to_sym))

        current_user.on_authorized if current_user.respond_to?(:on_authorized)
      end
    end

    helpers do
      # Halt processing and return a 401 Unauthorized.
      def unauthorized(body = nil)
        error 401, body
      end

      # Halt processing and return a 403 Forbidden.
      def access_denied(body = nil)
        error 403, body
      end
    end
  end
end