# frozen_string_literal: true

module Constants
  module Roles
    USER = :user
    # Administrator
    ADMIN = :admin
    # Power User
    POWER = :power
    MODERATOR = :moderator

    def self.new
      [USER, ADMIN, POWER, MODERATOR]
    end
  end
end
