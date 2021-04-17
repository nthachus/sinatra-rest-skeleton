# frozen_string_literal: true

RSpec.describe 'Rake app:delete_expired_sessions' do
  include_context 'rake'

  it 'invokes with invalid timeout' do
    expect { subject.invoke ' !' }.to raise_error(ArgumentError, /\bInvalid .*\bInteger\b/i)
  end

  it 'invokes with infinitive timeout' do
    expect { subject.invoke '604800 ' }.to output(/^\s*$/).to_stdout
  end

  it 'invokes to delete expired sessions' do
    expect(UserSession.create(user_id: 1, key: SecureRandom.uuid, updated_at: Time.now - 604_800)).to be_truthy
    expect { subject.invoke ' 604800' }.to output(/^1 expired sessions was deleted/).to_stdout
  end
end
