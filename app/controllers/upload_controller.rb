# frozen_string_literal: true

# Upload using tus protocol
# @see https://github.com/tus/tus-resumable-upload-protocol/blob/master/protocol.md
# @see https://github.com/kukhariev/node-uploadx
class UploadController < Skeleton::Application
  # Route prefix
  map '/upload'

  TUS_VERSIONS = '1.0.0'
  TUS_EXTENSIONS = 'creation,creation-with-upload,termination'
  TUS_CONTENT_TYPE = 'application/offset+octet-stream'

  before do
    headers['Tus-Resumable'] = TUS_VERSIONS # .first
  end

  options '/' do
    [
      204,
      { 'Tus-Extension' => TUS_EXTENSIONS, 'Tus-Version' => TUS_VERSIONS, 'Tus-Max-Size' => settings.max_upload_size.to_s },
      nil
    ]
  end

  # Create file from request and return file URL
  post '/', authorize: [] do
    metadata = parse_metadata env['HTTP_UPLOAD_METADATA']
    bad_request json_error(I18n.t('app.invalid_parameters', values: 'Metadata')) unless metadata
    bad_request json_error(I18n.t('app.missing_parameters', values: 'File name')) if object_empty? metadata[:name]

    metadata[:size] = suppress(TypeError, ArgumentError) { Integer(env['HTTP_UPLOAD_LENGTH'] || metadata[:size]) }
    bad_request json_error(I18n.t('app.missing_parameters', values: 'File size')) if metadata[:size].blank?
    error 413, json_error(I18n.t('app.file_size_too_large')) if metadata[:size] > settings.max_upload_size

    file_id = upload_service.create_file metadata
    error 409, json_error(I18n.t('app.file_already_exists', value: metadata[:name])) unless file_id

    headers['Location'] = "#{request.path}/#{file_id}"
    return_code = 201

    if request.media_type == TUS_CONTENT_TYPE
      written = upload_service.write_file file_id, request.body, Integer(request.content_length), metadata[:size]
      headers['Upload-Offset'] = written.to_s
      return_code = 200 if written.nonzero? && written < metadata[:size]
    end

    [return_code, nil]
  end

  # Delete upload by ID
  delete %r{/([0-9a-f]+)}, authorize: [] do |file_id|
    logger.info "Delete upload file: #{file_id.inspect}"

    file_path = upload_service.upload_file_path file_id
    not_found json_error(I18n.t('app.upload_file_not_found')) unless File.file? file_path

    upload_service.delete_file file_path
    [204, nil]
  end

  private

  # @param [String] encoded
  # @return [Hash]
  def parse_metadata(encoded)
    return {} if encoded.blank?

    Hash[
      encoded.lstrip.split(/(,\s*)+/).map do |kv|
        k, v = kv.split(/\s+/, 2)
        [k.to_sym, v.nil? ? true : force_encoding(Base64.strict_decode64(v))]
      end
    ]
  rescue ArgumentError => e
    logger.warn StackTraceArray.new(e, 0)
    nil
  end
end
