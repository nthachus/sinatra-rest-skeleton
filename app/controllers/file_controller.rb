# frozen_string_literal: true

class FileController < Skeleton::Application
  # Route prefix
  map '/file'

  # @!method file_service
  #   @return [Skeleton::FileService]

  get '/search', authorize: [] do
    list = file_service.search_user_file
    paths = file_service.user_file_dirs

    json files: list.as_json(except: %i[deleted_at deleted_by]), dirs: paths
  end

  get %r{/(\d+)/download}, authorize: [] do |file_id|
    file = file_service.find_user_file Integer(file_id)
    not_found json_error(I18n.t('app.upload_file_not_found')) unless file

    serve_file file.real_file_path, filename: file.name, type: file.media_type
  end

  delete %r{/(\d+)}, authorize: [] do |file_id|
    logger.info "Delete user file: #{file_id.inspect}"

    begin
      file_service.delete_user_file Integer(file_id)
      [204, nil]
    rescue ActiveRecord::RecordNotFound
      not_found json_error(I18n.t('app.upload_file_not_found'))
    end
  end
end
