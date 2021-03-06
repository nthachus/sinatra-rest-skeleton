# frozen_string_literal: true

require 'jwt'

module Skeleton
  class AuthService < BaseService
    # @param [String] username
    # @param [String] password
    # @return [String] JWT
    # @raise [ActiveModel::StrictValidationFailed]
    def login(username, password)
      user = User.has_password.find_by(username: username) || User.has_password.find_by!(email: username)
      raise ActiveModel::StrictValidationFailed, 'Bad credentials' unless user.authenticate password

      do_login user
    end

    # @param [User] user
    # @param [UserSession] session
    # @return [String] JWT
    def do_login(user, session = nil)
      session ||= UserSession.create! user: user, key: SecureRandom.uuid

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
        iss: @settings.jwt_issuer,
        iat: ts,
        exp: ts + @settings.jwt_lifetime,
        sub: user_id,
        jti: session_key
      )

      @logger.debug "Create JWT for: #{payload}"
      JWT.encode payload, @settings.jwt_secret
    end

    # @param [String] jwt
    # @return [User]
    # @raise [JWT::DecodeError]
    def authorize(jwt)
      payload = decode_jwt jwt

      user = User.find_by id: payload[:sub]
      raise JWT::InvalidSubError, 'User not found' unless user

      user.session = user.sessions.find_by key: payload[:jti]
      raise JWT::InvalidJtiError, 'Session not found' unless user.session

      user
    end

    private

    # @param [String] jwt
    # @return [Hash]
    def decode_jwt(jwt)
      decoded = JWT.decode jwt, @settings.jwt_secret, true, verify_iss: true, iss: @settings.jwt_issuer, verify_iat: true

      payload = decoded.first.with_indifferent_access
      @logger.debug "Authorize JWT payload: #{payload}"

      payload
    end
  end

  class Application < Sinatra::Base
    # @!method auth_service
    #   @return [AuthService]
    register_service AuthService

    private

    # @param [String] jwt
    # @return [User]
    def do_authorize(jwt)
      auth_service.authorize jwt
    end
  end
end
