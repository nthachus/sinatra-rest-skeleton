# frozen_string_literal: true

# @attr [Integer] id
# @attr [Integer] user_id
# @attr [String] key
# @attr [String] name
# @attr [Integer] size
# @attr [String] mime_type
# @attr [Integer] last_modified
# @attr [Hash] extra
# @attr [Time] created_at
# @attr [Time] updated_at
# noinspection RailsParamDefResolve
class Upload < ActiveRecord::Base
  # Validations
  validates :user_id, numericality: { only_integer: true }
  validates :key, presence: true, length: { maximum: 50, allow_blank: true } # uniqueness: { allow_blank: true }

  validates :name, not_empty: true, length: { maximum: 255 }
  validates :size, not_null: true, numericality: { only_integer: true, allow_nil: true }

  validates_length_of :mime_type, maximum: 255
  validates_numericality_of :last_modified, only_integer: true, allow_nil: true

  # Associations
  belongs_to :user, inverse_of: :uploads

  # @param [String] value
  def name=(value)
    super(value.is_a?(String) ? FileUtils.fix_relative_path(value) : value)
  end

  after_find do |o|
    o.name = o.name
  end

  # @return [Time, nil]
  def expiration_date
    updated_at ? updated_at + Skeleton::Application.settings.jwt_lifetime : nil
  end

  METADATA_KEYS = %i[name size mime_type last_modified].freeze

  # @param [Hash] data
  # @param [Hash] overrides
  # @return [self]
  def self.create_from_metadata(data, overrides = {})
    meta = data.dup
    create! meta.extract!(*METADATA_KEYS).merge!(extra: meta).merge!(overrides)
  end

  # @param [Hash] data
  def update_from_metadata(data)
    meta = data.dup
    assign_attributes meta.extract!(*METADATA_KEYS).merge!(extra: extra.merge!(meta))
    save!
  end

  # @return [Hash]
  def to_metadata
    extra.as_json.merge! as_json(only: METADATA_KEYS, methods: :name)
  end

  # @return [String, nil]
  def tmp_file_path
    return nil unless user_id.is_a?(Integer) && key.present?

    # @type [OpenStruct]
    settings = Skeleton::Application
    File.join File.expand_path(format(settings.upload_tmp_path, user_id), settings.root), key
  end

  # @return [Integer]
  def real_file_size
    path = tmp_file_path
    return File.size(path) if path && File.file?(path)

    path = out_file_path
    path && File.file?(path) ? File.size(path) : -1
  end

  # @return [String, nil]
  def out_file_path
    return nil unless user_id.is_a?(Integer) && name.present?

    # @type [OpenStruct]
    settings = Skeleton::Application
    File.join File.expand_path(format(settings.user_file_path, user_id), settings.root), name
  end
end
