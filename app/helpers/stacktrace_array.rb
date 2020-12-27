# frozen_string_literal: true

class StackTraceArray < Array
  # @param [Exception] err
  # @param [Integer] top
  # @param [Regexp] exclude
  # @return [Array<String>]
  def self.new(err, top = 1, exclude = %r{/ruby/})
    this = super(["#{err.class}: #{err.message}"])

    err.backtrace.each_with_index { |s, i| this.push(s) unless i > top && s =~ exclude }
    this
  end

  # @return [String]
  def inspect
    join "\n\t"
  end

  alias to_s inspect
end

class Exception
  # @param [Integer] top
  # @param [Regexp] exclude
  # @return [Array<String>]
  def stacktrace(top = 1, exclude = %r{/ruby/})
    StackTraceArray.new self, top, exclude
  end

  # @param [#send] out
  # @param [Symbol] method
  # @param [Integer] top
  def print_stacktrace(out, method = :warn, top = 0)
    out.send method, StackTraceArray.new(self, top)
  end
end
