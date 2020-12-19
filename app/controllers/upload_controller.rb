# frozen_string_literal: true

# Resumable upload using tus protocol
#
# @see https://tus.io/protocols/resumable-upload.html
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
    data = parse_metadata env['HTTP_UPLOAD_METADATA']
    bad_request json_error(I18n.t('app.invalid_parameters', values: 'Metadata')) unless data
    bad_request json_error(I18n.t('app.missing_parameters', values: 'File name')) if data[:name].nil_or_empty?

    data[:size] = suppress(TypeError, ArgumentError) { Integer(env['HTTP_UPLOAD_LENGTH'] || data[:size]) }
    bad_request json_error(I18n.t('app.missing_parameters', values: 'File size')) if data[:size].blank?
    error 413, json_error(I18n.t('app.file_size_too_large')) if data[:size] > settings.max_upload_size

    meta = create_upload_meta data
    headers['Location'] = "#{request.path}/#{meta.key}"
    return_code = 201

    if request.media_type == TUS_CONTENT_TYPE
      written = upload_service.write_file meta, request.body, Integer(request.content_length)
      headers['Upload-Offset'] = written.to_s
      return_code = 200 if written.nonzero? && written < meta.size
    end

    [return_code, nil]
  end

  FILE_ID_ROUTE = %r{/([0-9a-f]+)}.freeze

  # Write chunk to file and return chunk offset
  patch FILE_ID_ROUTE, authorize: [], media_type: TUS_CONTENT_TYPE do |file_id|
    meta = upload_service.find_upload_meta file_id
    # noinspection RubyArgCount
    not_found json_error(I18n.t('app.upload_file_not_found')) unless meta

    offset = suppress(TypeError, ArgumentError) { Integer(env['HTTP_UPLOAD_OFFSET']) }
    bad_request json_error(I18n.t('app.invalid_parameters', values: 'Offset')) if offset.blank? || offset.negative?

    data = parse_metadata env['HTTP_UPLOAD_METADATA']
    bad_request json_error(I18n.t('app.invalid_parameters', values: 'Metadata')) unless data
    data.delete(:name) if data[:name].nil_or_empty?

    data[:size] = suppress(TypeError, ArgumentError) { Integer(data[:size]) } unless data[:size].blank?
    data.delete(:size) if data[:size].blank?
    error 413, json_error(I18n.t('app.file_size_too_large')) if data[:size]&.send(:>, settings.max_upload_size)

    meta = update_upload_meta meta, data
    written = upload_service.write_file meta, request.body, Integer(request.content_length), offset

    [204, { 'Upload-Offset' => written.to_s }, nil]
  end

  head FILE_ID_ROUTE, authorize: [] do |file_id|
    begin
      meta = upload_service.find_upload_meta! file_id
      headers 'Upload-Offset' => meta.real_file_size.to_s, 'Upload-Metadata' => serialize_metadata(meta.to_metadata)

      nil
    rescue ActiveRecord::RecordNotFound => e
      logger.warn "#{e} - #{file_id.inspect}"
      not_found
    end
  end

  # Delete upload by ID
  delete FILE_ID_ROUTE, authorize: [] do |file_id|
    logger.info "Delete upload file: #{file_id.inspect}"

    begin
      upload_service.delete_file file_id
      [204, nil]
    rescue ActiveRecord::RecordNotFound
      # noinspection RubyArgCount
      not_found json_error(I18n.t('app.upload_file_not_found'))
    end
  end

  private

  # @param [Hash] meta
  # @return [Upload]
  def create_upload_meta(meta)
    upload_service.create_file meta
  rescue ActiveRecord::RecordNotUnique => e
    error 409, json_error(I18n.t('app.file_already_exists', value: e.message))
  rescue ActiveRecord::RecordInvalid => e
    # logger.warn e.to_s
    bad_request json_error(I18n.t('app.invalid_parameters', values: 'Metadata'), e.record.errors.to_a)
  end

  # @param [Upload] meta
  # @param [Hash] data
  # @return [Upload]
  def update_upload_meta(meta, data)
    upload_service.update_file meta, data
  rescue ActiveRecord::RecordNotUnique => e
    error 409, json_error(I18n.t('app.file_already_exists', value: e.message))
  rescue ActiveRecord::RecordInvalid => e
    # logger.warn e.to_s
    bad_request json_error(I18n.t('app.invalid_parameters', values: 'Metadata'), e.record.errors.to_a)
  end

  # @param [Hash] meta
  # @return [String]
  def serialize_metadata(meta)
    meta.select { |_, v| v }.map do |k, v|
      key = k.camelize :lower
      v.is_a?(TrueClass) ? key : "#{key} #{Base64.strict_encode64(v.to_s)}"
    end.join(',')
  end

  # @param [String] encoded
  # @return [Hash]
  def parse_metadata(encoded)
    return {} if encoded.blank?

    Hash[
      encoded.lstrip.split(/(?:,\s*)+/).map do |kv|
        k, v = kv.split(/\s+/, 2)
        [k.underscore.to_sym, v.nil? ? true : force_encoding(Base64.safe_decode64(v))]
      end
    ]
  rescue ArgumentError => e
    logger.warn StackTraceArray.new(e, 0)
    nil
  end
end
