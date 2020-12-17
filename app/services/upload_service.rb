# frozen_string_literal: true

module Skeleton
  class Application < Sinatra::Base
    # @return [UploadService]
    def upload_service
      @upload_service ||= UploadService.new self
    end
  end

  class UploadService
    def initialize(app)
      # @type [Skeleton::Application]
      @app = app
    end

    # @param [Hash] data
    # @option data [String] :name
    # @option data [Integer] :size
    # @return [Upload]
    # @raise [ActiveRecord::RecordNotUnique]
    def create_file(data)
      @app.logger.debug "Create upload file: #{data}"

      meta = Upload.from_metadata data, user: @app.current_user, key: SecureRandom.hex
      meta.save!

      File.open FileUtils.ensure_dir_exists(meta.real_file_path), 'w' do
        meta
      end
    rescue ActiveRecord::RecordInvalid => e
      raise ActiveRecord::RecordNotUnique if e.record.errors.details_for?(:filename, :taken)

      raise
    end

    # @param [Upload] meta
    # @param [IO] io
    # @param [Integer] length
    # @param [Integer] offset
    # @return [Integer]
    def write_file(meta, io, length, offset = 0)
      @app.logger.info "Write upload file: #{meta.key} - at: #{offset}"

      File.open meta.real_file_path, 'r+b' do |f|
        unless offset.zero?
          f.truncate offset if offset > f.size
          f.seek offset
        end

        IO.copy_stream io, f, [length, meta.size - offset].min
      end
    end

    # @param [String] file_id
    # @return [Upload]
    # @raise [ActiveRecord::RecordNotFound]
    def delete_file(file_id)
      meta = find_upload_meta file_id

      path = meta.real_file_path
      FileUtils.remove_file path if File.file? path

      meta.delete
    end

    # @param [String] file_id
    # @return [Upload]
    def find_upload_meta(file_id)
      @app.current_user.uploads.find_by! key: file_id
    end
  end
end
