# frozen_string_literal: true

# @attr [Integer] id
# @attr [String] role
# @attr [String] username
# @attr [String] password_digest
# @attr [String] name
# @attr [String] email
# @attr [Hash] profile
# @attr [DateTime] created_at
# @attr [DateTime] updated_at
# @attr [DateTime] deleted_at
# @attr [Integer] created_by
# @attr [Integer] updated_by
# @attr [Integer] deleted_by
class User < ActiveRecord::Base
  has_secure_password validations: false

  enum role: Constants::ROLES, _prefix: true

  # Validations
  validates :role, inclusion: { in: roles.keys }
  validates :username, presence: true, length: { maximum: 255 }, uniqueness: { allow_blank: true }

  validates_length_of :password, maximum: MAX_PASSWORD_LENGTH_ALLOWED
  validates_confirmation_of :password, allow_blank: true

  validates :name, presence: true, length: { maximum: 255 }
  validates :email, length: { maximum: 255, allow_nil: true }, uniqueness: { case_sensitive: false, allow_nil: true }
  validates_numericality_of :created_by, :updated_by, :deleted_by, only_integer: true, allow_nil: true

  # Associations
  has_many :sessions, class_name: :UserSession, inverse_of: :user

  # @return [true, false]
  def deleted?
    deleted_at.present?
  end

  # @return [UserSession]
  attr_accessor :session

  # Renew the session token
  def on_authorized
    session&.touch
  end
end