# frozen_string_literal: true

# @attr [Integer] id
# @attr [String] role
# @attr [String] username
# @attr [String] password_digest
# @attr [String] name
# @attr [String] email
# @attr [Hash] profile
# @attr [Time] created_at
# @attr [Time] updated_at
# @attr [Time] deleted_at
# @attr [Integer] created_by
# @attr [Integer] updated_by
# @attr [Integer] deleted_by
# noinspection RailsParamDefResolve
class User < ActiveRecord::Base
  has_secure_password validations: false

  # Scopes
  default_scope -> { where(deleted_at: nil) }
  scope :deleted, -> { unscoped.where.not(deleted_at: nil) }
  scope :has_password, -> { where.not(password_digest: nil) }

  # @!scope class
  # @!method roles
  #   @return [Hash]
  enum role: Constants::Roles.new, _suffix: true

  # Validations
  validates :role, inclusion: { in: roles.keys }
  validates :username, presence: true, length: { maximum: 255, allow_blank: true }
  validates_uniqueness_of :username, if: proc { |o| o.username.present? && o.username.length <= 255 }

  validates_length_of :password, maximum: MAX_PASSWORD_LENGTH_ALLOWED
  validates_confirmation_of :password, allow_nil: true

  validates :name, presence: true, length: { maximum: 255, allow_blank: true }
  validates :email, length: { maximum: 255 }, format: { with: URI::MailTo::EMAIL_REGEXP, allow_nil: true }
  validates_uniqueness_of :email, case_sensitive: false, if: proc { |o| o.email && o.email.length <= 255 }
  validates_numericality_of :created_by, :updated_by, :deleted_by, only_integer: true, allow_nil: true

  # Associations
  has_many :sessions, class_name: :UserSession, inverse_of: :user
  has_many :uploads, inverse_of: :user
  has_many :files, class_name: :UserFile, inverse_of: :user

  # @return [UserSession]
  attr_accessor :session

  private

  def on_authorized
    User.logger&.info "Authorized session: #{session&.key}"
  end
end
