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

  # @param [String] str
  def safe_decode64(str)
    str.gsub!(/\s+/, '')
    strict_decode64((str.length % 4).zero? ? str : str.ljust((str.length + 3) & ~3, '='))
  end
end

module YAML
  # Dump Ruby object +obj+ to a YAML file +filename+.
  #
  # @param [Object] obj
  # @param [String] filename
  # @param [Hash] options
  # @option options [Integer] :indentation
  def self.dump_to_file(obj, filename, options = {})
    File.open(filename, 'w:utf-8') { |f| dump obj, f, options }
  end
end

module FileUtils
  module_function

  # @param [String] path
  # @param [true, false] full
  # @return [String]
  def ensure_dir_exists(path, full = false)
    dir = full ? path : File.dirname(path)
    mkdir_p dir unless File.directory? dir
    path
  end
end

module ActiveModel
  class Errors
    # @return [true, false]
    def details_for?(attribute, error_type = nil)
      arr = details[attribute.to_sym]
      arr && !arr.empty? && (error_type.nil? || arr.any? { |o| o[:error] == error_type.to_sym })
    end
  end
end
