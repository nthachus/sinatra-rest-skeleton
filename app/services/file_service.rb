# frozen_string_literal: true

module Skeleton
  class FileService < BaseService
    # @param [Integer] file_id
    # @return [UserFile]
    def find_user_file(file_id)
      @app.current_user.files.find_by id: file_id
    end
  end

  Application.register_service FileService
end
