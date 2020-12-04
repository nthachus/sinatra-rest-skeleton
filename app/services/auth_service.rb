# frozen_string_literal: true

require 'jwt'

module Skeleton
  class Application < Sinatra::Base
    set :authorization_method, ->(jwt) { auth_service.authorize jwt }

    def auth_service
      @auth_service ||= AuthService.new self
    end
  end

  class AuthService
    # @param [Sinatra::Base] app
    def initialize(app)
      @app = app
    end

    # @param [String] username
    # @param [String] password
    # @return [String] JWT
    def login(username, password)
      user = User.find_by! username: username
      raise ActiveRecord::RecordNotFound, 'Bad credentials' unless user.authenticate password

      do_login user
    end

    # @param [User] user
    # @return [String] JWT
    def do_login(user)
      session = UserSession.create! user: user, key: SecureRandom.uuid

      create_jwt user.id, session.key, name: user.name, email: user.email, role: user.role
    end

    # @param [Integer] user_id
    # @param [String] session_key
    # @param [Hash] data
    # @option data [String] :name
    # @option data [String] :email
    # @option data [String] :role
    # @return [String]
    def create_jwt(user_id, session_key, data = {})
      ts = Time.now.to_i
      payload = data.merge(
        iss: @app.settings.jwt_issuer,
        iat: ts,
        exp: ts + @app.settings.jwt_lifetime,
        sub: user_id,
        jti: session_key
      )

      @app.logger.debug "Create JWT for: #{payload.inspect}"
      JWT.encode payload, @app.settings.jwt_secret
    end

    # @param [String] jwt
    # @return [User]
    def authorize(jwt)
      payload = decode_jwt jwt

      user = User.find_by id: payload[:sub]
      raise JWT::InvalidSubError, 'User not found' unless user&.id

      user.session = user.sessions.find_by key: payload[:jti]
      raise JWT::InvalidJtiError, 'Session not found' unless user.session

      user
    end

    private

    # @param [String] jwt
    # @return [Hash]
    def decode_jwt(jwt)
      decoded = JWT.decode jwt, @app.settings.jwt_secret, true, verify_iss: true, iss: @app.settings.jwt_issuer, verify_iat: true

      payload = decoded.first.with_indifferent_access
      @app.logger.debug "Authorize JWT payload: #{payload.inspect}"

      payload
    end
  end
end