# frozen_string_literal: true

RSpec.describe 'Rake app:delete_expired_sessions' do
  include_context 'rake'

  it 'invokes with invalid timeout' do
    expect { subject.invoke ' !' }.to raise_error(ArgumentError, /\bInvalid .*\bInteger\b/i)
  end

  it 'invokes with infinitive timeout' do
    expect { subject.invoke '604800 ' }.to output(/^0 expired sessions was deleted/).to_stdout
  end
end
