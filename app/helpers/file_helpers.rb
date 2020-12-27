# frozen_string_literal: true

module FileHelpers
  class << self
    # Computes the SHA256 hash of the file specified by +path+.
    #
    # @param [String] path
    # @return [String]
    def checksum(path)
      # noinspection RubyResolve
      path && File.file?(path) ? Digest::SHA256.file(path).hexdigest : nil
    end

    # Detects type and encoding of the file specified by +path+.
    #
    # @param [String] path
    # @return [Array<String>, String]
    def identify_type(path)
      return nil unless path
      return Rack::Mime.mime_type(File.extname(path)) unless File.size? path

      # @type [String] mime
      mime, charset = detect_mime path
      charset = detect_charset(path) if mime =~ %r{^text/} && charset !~ /^utf/

      [mime, charset]
    end

    # Determine file type.
    #
    # @param [String] path
    # @return [Array<String>]
    def detect_mime(path)
      out = Process.run_command 'file', '-bi', path
      raise out unless out =~ /^\S+(\s*;|$)/

      out.split(/\s*(?:;(?:\s*charset\s*=)?\s*)+/i)
    end

    # Guess character encoding of a file.
    #
    # @param [String] path
    # @return [String]
    def detect_charset(path)
      Process.run_command 'uchardet', path
    rescue Errno::ENOENT
      # :nocov:
      Process.run_command 'encguess', path
      # :nocov:
    end
  end

  # TODO: def ...
end

module Skeleton
  # Load the helpers in modular style automatically
  Application.helpers FileHelpers
end
