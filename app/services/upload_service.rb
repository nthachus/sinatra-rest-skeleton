# frozen_string_literal: true

module Skeleton
  class UploadService < BaseService
    # @param [Hash] data
    # @return [Upload]
    # @raise [ActiveRecord::RecordNotUnique]
    def create_file(data)
      @logger.debug "Create upload file: #{data}"

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
      @logger.debug "Update upload file: #{meta.key} - #{data}"

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
      @logger.info "Write upload file: #{meta.key} - at: #{offset}"

      if meta.size > offset
        offset += File.open(meta.tmp_file_path, 'r+b') do |f|
          f.seek offset unless offset.zero?

          IO.copy_stream io, f, [length, meta.size - offset].min
        end
      end

      on_complete meta if offset >= meta.size
      offset
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
    def on_complete(meta)
      @logger.info "Upload completed: #{meta.key} - #{meta.name.inspect}"

      # TODO: UserFile.create_from_upload meta
      File.rename meta.tmp_file_path, FileUtils.ensure_dir_exists(path = meta.out_file_path)
      File.utime(Time.now, Time.fix_timestamp(meta.last_modified), path) if meta.last_modified
    end
  end

  class Application < Sinatra::Base
    # @!method upload_service
    #   @return [UploadService]
    register_service UploadService
  end
end
