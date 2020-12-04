# frozen_string_literal: true

# @attr [Integer] id
# @attr [Integer] user_id
# @attr [String] key
# @attr [Hash] value
# @attr [DateTime] created_at
# @attr [DateTime] updated_at
class UserSession < ActiveRecord::Base
  # Validations
  validates :user_id, numericality: { only_integer: true }
  validates :key, presence: true, length: { maximum: 50 }, uniqueness: { allow_blank: true }

  # Associations
  belongs_to :user, inverse_of: :sessions
end
