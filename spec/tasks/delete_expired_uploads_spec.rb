# frozen_string_literal: true

RSpec.describe 'Rake app:delete_expired_uploads' do
  include_context 'rake'

  before :all do
    FileUtils.touch Skeleton::Application::PID_FILE
  end

  it 'invokes with invalid timeout' do
    expect { subject.invoke ' !' }.to raise_error(ArgumentError, /\bInvalid .*\bInteger\b/i)
  end

  it 'invokes with infinitive timeout' do
    expect { subject.invoke '604800 ' }.to output(/^\s*$/).to_stdout
  end

  it 'invokes to delete obsoleted files' do
    expect(o = Upload.create(user_id: 1, key: SecureRandom.hex, name: '!', size: 0, updated_at: Time.now - 604_800)).to be_truthy
    expect(FileUtils.touch(FileUtils.ensure_dir_exists(o.tmp_file_path))).to be_truthy

    expect { subject.invoke ' 604800' }.to output(%r{^1 expired uploads / 1 obsoleted files was deleted}).to_stdout
  end
end
