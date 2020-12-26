# frozen_string_literal: true

require 'rack/auth/abstract/request'

module Skeleton
  # Authentication and Authorization with JWT in Sinatra
  class Application < Sinatra::Base
    # @return [User]
    attr_reader :current_user

    before do
      if !request.options? && (token = authorization_token).first
        begin
          # noinspection RailsParamDefResolve
          @current_user = respond_to?(:do_authorize, true) ? send(:do_authorize, token.last) : nil
        rescue JWT::ExpiredSignature => e
          logger.warn StackTraceArray.new(e, 0)
          unauthorized json_error(I18n.t('app.expired_token'), settings.production? ? nil : e.to_s)
        rescue JWT::DecodeError => e
          logger.error(stacktrace = StackTraceArray.new(e))
          unauthorized json_error(I18n.t('app.invalid_token'), settings.production? ? e.to_s : stacktrace)
        end
      end
    end

    # A way to require authorization
    #
    # @example
    #   get '/', authorize: [:admin] do
    #     ...
    #   end
    #
    set(:authorize) do |*roles|
      condition do
        # Make sure it's logged-in
        unauthorized json_error(I18n.t('app.missing_token')) unless current_user

        access_denied json_error(I18n.t('app.access_denied')) \
          if roles.present? && current_user.respond_to?(:role) && !roles.include?(current_user.role&.to_sym)

        current_user.send(:on_authorized) if current_user.respond_to?(:on_authorized, true)
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

      # @return [Array<#nil?, String>]
      def authorization_token(req = Rack::Auth::AbstractRequest.new(env))
        return [true, req.scheme == 'bearer' ? req.parts[1] : nil] if req.provided?

        hsh = request.params
        hsh.key?('token') ? [request.path =~ Regexp.new(settings.token_authorization_urls), hsh['token']] : []
      end
    end
  end
end
