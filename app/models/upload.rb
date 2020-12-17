# frozen_string_literal: true

# @attr [Integer] id
# @attr [Integer] user_id
# @attr [String] key
# @attr [String] path
# @attr [String] filename
# @attr [Integer] size
# @attr [String] mime_type
# @attr [Integer] last_modified
# @attr [Hash] extra
# @attr [DateTime] created_at
# @attr [DateTime] updated_at
# @attr [Integer] created_by
# @attr [Integer] updated_by
# noinspection RailsParamDefResolve
class Upload < ActiveRecord::Base
  # Validations
  validates :user_id, numericality: { only_integer: true }
  validates :key, presence: true, length: { maximum: 50, allow_blank: true } # uniqueness: { allow_blank: true }

  validates_length_of :path, maximum: 255
  validates :filename, not_empty: true, length: { maximum: 255 }
  validates_uniqueness_of(
    :filename,
    scope: %i[user_id path],
    if: proc { |o| o.filename && o.user_id.is_a?(Integer) && o.path && o.path.length <= 255 && o.filename.length.between?(1, 255) }
  )

  validates_numericality_of :size, only_integer: true
  validates_length_of :mime_type, maximum: 255
  validates_numericality_of :last_modified, :created_by, :updated_by, only_integer: true, allow_nil: true

  # Associations
  belongs_to :user, inverse_of: :uploads

  # @return [String]
  def name
    filename.nil? ? nil : File.join(path || '.', filename)
  end

  # @param [String] value
  def name=(value)
    self.filename, self.path = value.nil? ? nil : [File.basename(value), File.dirname(value)]
  end

  METADATA_KEYS = %i[name size mime_type last_modified].freeze

  # @param [Hash] data
  # @param [Hash] overrides
  # @return [self]
  def self.from_metadata(data, overrides = {})
    meta = data.dup
    new meta.extract!(*METADATA_KEYS).merge(extra: meta).merge(overrides)
  end

  # @return [Hash]
  def to_metadata
    extra.as_json.merge as_json(only: METADATA_KEYS, methods: :name)
  end

  # @return [String]
  def real_file_path
    return nil if !user_id.is_a?(Integer) || key.blank?

    File.join File.expand_path(format(Skeleton::Application.settings.user_file_path, user_id), Skeleton::Application.settings.root), key
  end

  # @return [Integer]
  def real_file_size
    return nil unless (path = real_file_path)

    File.file?(path) ? File.size(path) : -1
  end
end
