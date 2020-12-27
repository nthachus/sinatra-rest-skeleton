# frozen_string_literal: true

class Object
  # An object is empty if it's nil, false, or empty.
  #
  # @return [true, false]
  def nil_or_empty?
    respond_to?(:empty?) ? empty? : !self
  end
end

module Base64
  module_function

  # Decodes a Base64 encoded +str+.
  # Whitespace characters will be silently discarded.
  #
  # @param [String] str
  # @raise [ArgumentError] If +str+ contains non-alphabet characters.
  def safe_decode64(str)
    str.gsub!(/\s+/, '')
    str = str.ljust((str.length + 3) & ~3, '=') if (str.length % 4).nonzero?
    strict_decode64 str
  end
end

module FileUtils
  # Checks whether the directory exists and creates it if necessary.
  #
  # @param [String] path
  # @param [true, false] full
  # @return [String]
  def ensure_dir_exists(path, full = false)
    dir = full ? path : File.dirname(path)
    mkdir_p dir unless File.directory? dir
    path
  end

  # Remove dot-segments from the specified relative path.
  #
  # @param [String] path
  # @return [String]
  def fix_relative_path(path)
    File.expand_path(path, '/')[File.expand_path('/').length..-1]
  end

  module_function :ensure_dir_exists, :fix_relative_path
end

class Time
  # Convert timestamp in milliseconds, microseconds,... to seconds with fractions.
  #
  # @param [Integer] timestamp
  # @return [Numeric]
  def self.fix_timestamp(timestamp)
    str = timestamp.to_s
    str.length > 10 ? str.insert(10, '.').to_f : timestamp
  end
end

module ActiveModel
  class Errors
    # Returns +true+ if the model validation has errors (of the optional type) for the given +attribute+.
    #
    # @return [true, false]
    def details_for?(attribute, error_type = nil)
      arr = details[attribute.to_sym]
      arr && !arr.empty? && (error_type.nil? || arr.any? { |o| o[:error] == error_type.to_sym })
    end
  end
end

module Process
  # Returns the trimmed standard output of a command.
  #
  # @param [Array<String>] cmd
  # @option [String] :chdir
  # @return [String]
  # @raise [RuntimeError] If the process has a non-zero exit code.
  # @raise [Errno::ENOENT] If the command was not found.
  def self.run_command(*cmd)
    require 'open3'

    out, err, status = Open3.capture3(*cmd)
    out.strip!
    raise(err.blank? ? out : err.strip) unless status.success?

    out
  end
end
