# frozen_string_literal: true

# Upload using tus protocol
# @see https://github.com/tus/tus-resumable-upload-protocol/blob/master/protocol.md
# @see https://github.com/kukhariev/node-uploadx
class UploadController < Skeleton::Application
  TUS_VERSIONS = '1.0.0'
  TUS_EXTENSIONS = 'creation,creation-with-upload,termination'
  TUS_CONTENT_TYPE = 'application/offset+octet-stream'

  # Route prefix
  map '/upload'

  before do
    headers['Tus-Resumable'] = TUS_VERSIONS # .first
  end

  options '/' do
    [204, { 'Tus-Extension' => TUS_EXTENSIONS, 'Tus-Version' => TUS_VERSIONS, 'Tus-Max-Size' => settings.max_upload_size }, nil]
  end

  # Create file from request and return file URL
  post '/', authorize: [] do
    metadata = parse_metadata env['HTTP_UPLOAD_METADATA']
    bad_request json_error(I18n.t('app.invalid_parameters', values: 'Metadata')) unless metadata
    bad_request json_error(I18n.t('app.missing_parameters', values: 'File name')) if object_empty? metadata[:name]

    metadata[:size] = suppress(TypeError, ArgumentError) { Integer(env['HTTP_UPLOAD_LENGTH'] || metadata[:size]) }
    bad_request json_error(I18n.t('app.missing_parameters', values: 'File size')) if metadata[:size].blank?

    file_id = upload_service.create_file metadata # File.open { .truncate }
    headers['Location'] = "#{request.url}/#{file_id}"

    written = 0
    if request.media_type == TUS_CONTENT_TYPE
      written = upload_service.write_file file_id, request.body, Integer(request.content_length) # copy_stream
      headers['Upload-Offset'] = written
    end

    status 201 if written.zero? || written >= metadata[:size]
    nil
  end

  private

  def parse_metadata(encoded)
    return {} if encoded.blank?

    Hash[
      encoded.strip.split(/\s*(,\s*)+/).map do |kv|
        k, v = kv.split(/\s+/, 2)
        [k.to_sym, v.nil? ? true : Base64.strict_decode64(v)]
      end
    ]
  rescue ArgumentError => e
    logger.warn e.inspect
    nil
  end
end
