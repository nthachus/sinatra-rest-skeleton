# frozen_string_literal: true

class FileController < Skeleton::Application
  # Route prefix
  map '/file'

  # @!method file_service
  #   @return [Skeleton::FileService]

  get '/search', authorize: [] do
    list = file_service.search_user_file params
    paths = file_service.user_file_dirs

    json files: list.as_json(except: %i[deleted_by]), dirs: paths
  end

  get %r{/(\d+)/download}, authorize: [] do |file_id|
    file = file_service.find_user_file Integer(file_id)
    not_found json_error(I18n.t('app.upload_file_not_found')) unless file

    serve_file file.real_file_path, filename: file.name, type: file.media_type
  end

  delete %r{/(\d+(?:\s*,\s*\d+)*)}, authorize: [] do |file_ids|
    logger.info "Delete user file(s): #{file_ids.inspect}"

    begin
      file_service.delete_user_files parse_id_list(file_ids)
      [204, nil]
    rescue ActiveRecord::RecordNotFound => e
      not_found json_error(I18n.t('app.upload_file_not_found'), e.to_s)
    end
  end

  post %r{/(\d+(?:\s*,\s*\d+)*)/undelete}, authorize: [] do |file_ids|
    logger.info "Undelete user file(s): #{file_ids.inspect}"

    begin
      file_service.undelete_user_files parse_id_list(file_ids)
      [204, nil]
    rescue ActiveRecord::RecordNotFound => e
      not_found json_error(I18n.t('app.upload_file_not_found'), e.to_s)
    end
  end

  private

  # @param [String] ids
  # @return [Array<Integer>]
  def parse_id_list(ids)
    ids.split(/\s*(?:,\s*)+/).map(&method(:Integer))
  end
end
