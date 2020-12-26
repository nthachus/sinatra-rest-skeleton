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
end
