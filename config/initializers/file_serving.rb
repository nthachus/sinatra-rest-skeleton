# frozen_string_literal: true

module Skeleton
  module FileServing
    # Send the file at +path+ to the client for downloading.
    #
    # @param [String] path
    # @option opts [String] :filename
    # @option opts [String] :type
    def serve_file(path, opts = {})
      mime = mime_type opts[:type]
      hdr = headers_for_download(opts[:filename] || path)

      file = file_serving_handler hdr, mime
      result = file.serving request, path

      halt(*result)
    rescue Errno::ENOENT => e
      e.print_stacktrace logger

      not_found json_error(I18n.t('app.resource_not_found'), e.to_s)
    end

    private

    # @param [String] filename
    # @return [Hash]
    def headers_for_download(filename)
      {
        'Accept-Ranges' => 'bytes',
        'Content-Disposition' => "attachment; filename=\"#{File.basename(filename).gsub(/[\\"]/, '\\\\\0')}\"",
        'Content-Transfer-Encoding' => 'binary'
      }
    end

    # @param [Hash] hdr
    # @param [String] mime
    # @return [Rack::Files]
    def file_serving_handler(hdr = {}, mime = nil)
      file = Rack::Files.new nil, hdr, 'application/octet-stream'

      file.singleton_class.redefine_method(:mime_type) { |*| mime } if mime
      file
    end
  end

  Application.helpers FileServing
end
