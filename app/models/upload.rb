# frozen_string_literal: true

# @attr [Integer] id
# @attr [Integer] user_id
# @attr [String] key
# @attr [String] name
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

  validates :name, not_empty: true, length: { maximum: 255 }
  # validates_uniqueness_of :name, scope: :user_id, if: proc { |o| o.name && o.user_id.is_a?(Integer) && o.name.length.between?(1, 255) }

  validates_numericality_of :size, only_integer: true
  validates_length_of :mime_type, maximum: 255
  validates_numericality_of :last_modified, :created_by, :updated_by, only_integer: true, allow_nil: true

  # Associations
  belongs_to :user, inverse_of: :uploads

  # @param [String] value
  def name=(value)
    super(value.is_a?(String) ? FileUtils.fix_relative_path(value) : value)
  end

  METADATA_KEYS = %i[name size mime_type last_modified].freeze

  # @param [Hash] data
  # @param [Hash] overrides
  # @return [self]
  def self.create_from_metadata(data, overrides = {})
    meta = data.dup
    create! meta.extract!(*METADATA_KEYS).merge(extra: meta).merge(overrides)
  end

  # @param [Hash] data
  def update_from_metadata(data)
    meta = data.dup
    assign_attributes meta.extract!(*METADATA_KEYS).merge(extra: extra.merge(meta))
    save!
  end

  # @return [Hash]
  def to_metadata
    extra.as_json.merge as_json(only: METADATA_KEYS, methods: :name)
  end

  # @return [String]
  def tmp_file_path
    return nil if !user_id.is_a?(Integer) || key.blank?

    File.join File.expand_path(format(Skeleton::Application.settings.upload_tmp_path, user_id), Skeleton::Application.settings.root), key
  end

  # @return [Integer]
  def tmp_file_size
    return nil unless (path = tmp_file_path)

    File.file?(path) ? File.size(path) : -1
  end

  # @return [String]
  def out_file_path
    return nil if !user_id.is_a?(Integer) || name.blank?

    File.join File.expand_path(format(Skeleton::Application.settings.user_file_path, user_id), Skeleton::Application.settings.root), name
  end

  private

  def on_complete
    Upload.logger&.info "Upload completed: #{key} - #{name.inspect}"

    File.rename tmp_file_path, FileUtils.ensure_dir_exists(path = out_file_path)
    File.utime(Time.now, Time.fix_timestamp(last_modified), path) if last_modified
  end
end
