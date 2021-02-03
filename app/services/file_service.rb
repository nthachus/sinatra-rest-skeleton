# frozen_string_literal: true

module Skeleton
  class FileService < BaseService
    # @param [Integer] file_id
    # @return [UserFile]
    def find_user_file(file_id)
      @app.current_user.files.find_by id: file_id
    end

    # @param [UserFile] file
    # @param [Integer] user_id
    def delete_user_file(file, user_id = nil)
      if file.deleted_at
        path = file.real_file_path
        FileUtils.remove_entry path if File.exist? path

        file.delete
      else
        file.assign_attributes deleted_at: Time.now, deleted_by: user_id
        file.save! touch: false
      end
    end

    # @param [Array<Integer>] file_ids
    # @param [Integer] user_id
    # @raise [ActiveRecord::RecordNotFound]
    def delete_user_files(file_ids, user_id = @app.current_user.id)
      files = UserFile.unscoped.where id: file_ids, user_id: user_id

      remains = file_ids - files.map(&:id)
      raise ActiveRecord::RecordNotFound, "Couldn't find #{UserFile} with ID: #{remains.inspect}" unless remains.empty?

      UserFile.transaction do
        files.each { |file| delete_user_file file, user_id }
      end
    end

    # @param [UserFile] file
    # @param [Integer] user_id
    def undelete_user_file(file, user_id = nil)
      file.update! deleted_at: nil, updated_by: user_id
    end

    # @param [Array<Integer>] file_ids
    # @param [Integer] user_id
    # @raise [ActiveRecord::RecordNotFound]
    def undelete_user_files(file_ids, user_id = @app.current_user.id)
      files = UserFile.deleted.where id: file_ids, user_id: user_id

      remains = file_ids - files.map(&:id)
      raise ActiveRecord::RecordNotFound, "Couldn't find deleted #{UserFile} with ID: #{remains.inspect}" unless remains.empty?

      UserFile.transaction do
        files.each { |file| undelete_user_file file }
      end
    end

    # @return [Array<String>]
    def user_file_dirs
      path = @app.current_user.base_file_path
      return nil unless File.directory? path

      Dir.chdir path do
        Dir.glob('**').select { |f| File.directory? f }
      end
    end

    # @param [Hash] params
    # @return [Array<UserFile>]
    def search_user_file(params = {})
      q = params.key?(:deleted) ? UserFile.deleted : UserFile
      q.where(user_id: @app.current_user.id)
    end
  end

  Application.register_service FileService
end
