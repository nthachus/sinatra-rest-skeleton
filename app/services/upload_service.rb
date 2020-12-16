# frozen_string_literal: true

module Skeleton
  class Application < Sinatra::Base
    # @return [UploadService]
    def upload_service
      @upload_service ||= UploadService.new self
    end

    helpers do
      # @param [String] path
      # @param [true, false] is_dir
      # @return [String]
      def ensure_path_exists(path, is_dir = false)
        dir = is_dir ? path : File.dirname(path)
        FileUtils.mkdir_p dir unless File.directory? dir
        path
      end
    end
  end

  class UploadService
    def initialize(app)
      # @type [Skeleton::Application]
      @app = app
    end

    # @param [Hash] meta
    # @option meta [String] :name
    # @option meta [Integer] :size
    # @return [String]
    def create_file(meta)
      @app.logger.debug "Create upload file: #{meta}"
      return nil if File.file? user_file_path(meta[:name])

      file_id = SecureRandom.hex
      File.open @app.ensure_path_exists(upload_file_path(file_id)), 'wb' do |f|
        # f.truncate meta[:size]
        YAML.dump_to_file meta, meta_file_path(f.path)
        file_id
      end
    end

    # @param [String] file_id
    # @param [IO] io
    # @param [Integer] length
    # @param [Integer] size
    # @param [Integer] offset
    # @return [Integer]
    def write_file(file_id, io, length, size, offset = 0)
      @app.logger.info "Write upload file: #{file_id.inspect} - at: #{offset}"

      File.open upload_file_path(file_id), 'r+b' do |f|
        unless offset.zero?
          f.truncate offset if offset > f.size
          f.seek offset
        end

        IO.copy_stream io, f, [length, size - offset].min
      end
    end

    # @param [String] file_path
    # @return [Integer, nil]
    def delete_file(file_path)
      path = meta_file_path file_path
      FileUtils.remove_file path if File.file? path

      FileUtils.remove_file file_path
    end

    # @param [String] name
    # @return [String]
    def user_file_path(name)
      File.expand_path File.join(format(@app.settings.user_file_path, @app.current_user.id), name), @app.settings.root
    end

    # @param [String] filename
    # @return [String]
    def upload_file_path(filename)
      File.expand_path File.join(format(@app.settings.upload_tmp_path, @app.current_user.id), filename), @app.settings.root
    end

    # @param [String] file_path
    # @return [String]
    def meta_file_path(file_path)
      "#{file_path}.meta"
    end
  end
end
