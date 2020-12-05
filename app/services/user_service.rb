# frozen_string_literal: true

module Skeleton
  class Application < Sinatra::Base
    # @return [UserService]
    def user_service
      @user_service ||= UserService.new self
    end
  end

  class UserService
    # @param [Sinatra::Base] app
    def initialize(app)
      @app = app
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
