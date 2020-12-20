# frozen_string_literal: true

# @attr [Integer] id
# @attr [Integer] user_id
# @attr [String] name
# @attr [Integer] size
# @attr [String] media_type
# @attr [String] encoding
# @attr [Integer] last_modified
# @attr [String] checksum
# @attr [Hash] extra
# @attr [Time] created_at
# @attr [Time] updated_at
# @attr [Time] deleted_at
# @attr [Integer] created_by
# @attr [Integer] updated_by
# @attr [Integer] deleted_by
# noinspection RailsParamDefResolve
class UserFile < ActiveRecord::Base
  # Scopes
  default_scope -> { where(deleted_at: nil) }
  scope :deleted, -> { unscoped.where.not(deleted_at: nil) }

  # Validations
  validates :user_id, numericality: { only_integer: true }
  validates :name, not_empty: true, length: { maximum: 255 }
  validates_uniqueness_of :name, scope: :user_id, if: proc { |o| o.name && o.user_id.is_a?(Integer) && o.name.length.between?(1, 255) }

  validates_numericality_of :size, only_integer: true
  validates_length_of :media_type, maximum: 120
  validates_length_of :encoding, maximum: 50

  validates_numericality_of :last_modified, :created_by, :updated_by, :deleted_by, only_integer: true, allow_nil: true
  validates :checksum, length: { maximum: 100 }, format: { with: /\A[0-9a-f]+\z/, allow_nil: true }

  # Associations
  belongs_to :user, inverse_of: :files

  # @param [String] value
  def name=(value)
    super(value.is_a?(String) ? FileUtils.fix_relative_path(value) : value)
  end

  after_find do |o|
    o.name = o.name
  end

  # @param [Upload] meta
  # @return [self]
  def self.create_from_upload(meta, &block)
    transaction do
      o = new meta.attributes.slice('user_id', 'name', 'size', 'last_modified', 'extra')
      o.save!(&block)
      o
    end
  end

  # @return [String, nil]
  def real_file_path
    return nil unless user_id.is_a?(Integer) && name.present?

    # @type [OpenStruct]
    settings = Skeleton::Application
    File.join File.expand_path(format(settings.user_file_path, user_id), settings.root), name
  end
end
