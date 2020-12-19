# frozen_string_literal: true

module Skeleton
  class UserService < BaseService
    # @param [String] username
    # @param [String] email
    # @return [User]
    # @raise [ActiveRecord::RecordNotFound]
    def find_first(username, email)
      user = username.blank? ? nil : User.find_by(username: username)
      user = User.find_by(email: email) if !user && email.present?
      raise ActiveRecord::RecordNotFound, 'User not found' unless user

      user
    end

    # @return [Array<User>]
    def find_all
      user_role = User.arel_table[:role]

      User.unscoped.includes(:sessions).where(
        user_role.eq(User.roles[Constants::Roles::USER]).or(user_role.gteq(User.roles[@app.current_user.role]))
      )
    end
  end

  class Application < Sinatra::Base
    # @!method user_service
    #   @return [UserService]
    register_service UserService
  end
end
