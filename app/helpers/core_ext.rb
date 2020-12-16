# frozen_string_literal: true

module YAML
  # Dump Ruby object +obj+ to a YAML file +filename+.
  #
  # @param [Object] obj
  # @param [String] filename
  # @param [Hash] options
  # @option options [Integer] :indentation
  def self.dump_to_file(obj, filename, options = {})
    File.open(filename, 'w:utf-8') { |io| dump obj, io, options }
  end
end
