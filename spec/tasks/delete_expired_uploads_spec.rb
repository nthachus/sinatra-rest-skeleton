# frozen_string_literal: true

RSpec.describe 'Rake app:delete_expired_uploads' do
  include_context 'rake'

  it 'invokes with invalid timeout' do
    expect { subject.invoke ' !' }.to raise_error(ArgumentError, /\bInvalid .*\bInteger\b/i)
  end

  it 'invokes with infinitive timeout' do
    expect { subject.invoke '604800 ' }.to output(%r{^0 expired uploads / 0 obsoleted files was deleted}).to_stdout
  end

  it 'invokes to delete obsoleted files' do
    FileUtils.touch File.expand_path("../../tmp/uploads/2/#{SecureRandom.hex}", __dir__)
    expect { subject.invoke ' 604800' }.to output(%r{^0 expired uploads / 1 obsoleted files was deleted}).to_stdout
  end
end
