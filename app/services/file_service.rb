# frozen_string_literal: true

module Skeleton
  class FileService < BaseService
    # @param [Integer] file_id
    # @return [UserFile]
    def find_user_file(file_id)
      @app.current_user.files.find_by id: file_id
    end

    # @return [Array<String>]
    def user_file_dirs
      Dir.chdir @app.current_user.base_file_path do
        Dir.glob('**').select { |f| File.directory? f }
      end
    end

    # @return [Array<UserFile>]
    def search_user_file
      UserFile.where(user_id: @app.current_user.id)
    end
  end

  Application.register_service FileService
end
