# frozen_string_literal: true

module Skeleton
  class Application < Sinatra::Base
    # @return [UserService]
    def user_service
      @user_service ||= UserService.new self
    end
  end

  class UserService
    def initialize(app)
      # @type [Skeleton::Application]
      @app = app
    end

    # @param [String] username
    # @param [String] email
    # @return [User]
    def find_first(username, email)
      user = User.find_by(username: username) if username.present?
      return user if user&.id

      user = User.find_by(email: email) if email.present?
      return user if user&.id

      raise ActiveRecord::RecordNotFound, 'User not found'
    end

    def find_all
      User.unscoped.includes(:sessions).where(
        'role = ? OR role >= ?',
        User.roles[Constants::Roles::USER],
        User.roles[@app.current_user.role]
      )
    end
  end
end
