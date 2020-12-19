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
    # @return [Upload]
    # @raise [ActiveRecord::RecordNotUnique]
    def create_file(data)
      @app.logger.debug "Create upload file: #{data}"

      Upload.transaction do
        meta = Upload.create_from_metadata data, user: @app.current_user, key: SecureRandom.hex
        raise ActiveRecord::RecordNotUnique, meta.name if File.exist? meta.out_file_path

        # noinspection RubyArgCount
        FileUtils.touch FileUtils.ensure_dir_exists(meta.tmp_file_path) if meta.size >= 0
        meta
      end
    end

    # @param [Upload] meta
    # @param [Hash] data
    # @return [Upload]
    # @raise [ActiveRecord::RecordNotUnique]
    def update_file(meta, data)
      @app.logger.debug "Update upload file: #{meta.key} - #{data}"

      Upload.transaction do
        meta.update_from_metadata data
        raise ActiveRecord::RecordNotUnique, meta.name if File.exist? meta.out_file_path

        # noinspection RubyArgCount
        FileUtils.touch FileUtils.ensure_dir_exists(meta.tmp_file_path) if meta.size >= 0
        meta
      end
    end

    # @param [Upload] meta
    # @param [IO] io
    # @param [Integer] length
    # @param [Integer] offset
    # @return [Integer]
    def write_file(meta, io, length, offset = 0)
      @app.logger.info "Write upload file: #{meta.key} - at: #{offset}"

      if meta.size > offset
        offset += File.open(meta.tmp_file_path, 'r+b') do |f|
          f.seek offset unless offset.zero?

          IO.copy_stream io, f, [length, meta.size - offset].min
        end
      end

      on_written meta, offset
    end

    # @param [String] file_id
    # @return [Upload]
    # @raise [ActiveRecord::RecordNotFound]
    def delete_file(file_id)
      meta = find_upload_meta! file_id

      path = meta.tmp_file_path
      FileUtils.remove_entry path if File.exist? path

      meta.delete
    end

    # @param [String] file_id
    # @return [Upload]
    def find_upload_meta(file_id)
      @app.current_user.uploads.find_by key: file_id
    end

    # @param [String] file_id
    # @return [Upload]
    def find_upload_meta!(file_id)
      @app.current_user.uploads.find_by! key: file_id
    end

    private

    # @param [Upload] meta
    # @param [Integer] written
    # @return [Integer]
    def on_written(meta, written)
      meta.send(:on_complete) if written >= meta.size && meta.respond_to?(:on_complete, true)
      written
    end
  end
end
