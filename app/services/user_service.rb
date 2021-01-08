# frozen_string_literal: true

module Skeleton
  class UserService < BaseService
    # @param [String] username
    # @param [String] email
    # @return [User]
    # @raise [ActiveRecord::RecordNotFound]
    def find_user(username, email = nil)
      user = username.blank? ? nil : User.find_by(username: username)
      user = User.find_by(email: email) if !user && email.present?
      raise ActiveRecord::RecordNotFound, 'User not found' unless user

      user
    end

    # @return [Array<User>]
    def search_user
      user_role = User.arel_table[:role]
      user_roles = User.roles

      User.unscoped.includes(:sessions).where(
        user_role.eq(user_roles[Constants::Roles::USER]).or(user_role.gteq(user_roles[@app.current_user.role]))
      )
    end
  end

  Application.register_service UserService
end
