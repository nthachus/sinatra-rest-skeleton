# frozen_string_literal: true

RSpec.describe StackTraceArray do
  it 'initializes for an exception' do
    begin
      raise 'Oops!'
    rescue RuntimeError => e
      message = 'RuntimeError: Oops!'
      pattern = /^#{message}\n\t.*\b#{File.basename(__FILE__)}:6:/

      expect(e.stacktrace).to be_kind_of(Array) & have_attributes(size: 3, first: message, inspect: match(pattern), to_s: match(pattern))
    end
  end
end
