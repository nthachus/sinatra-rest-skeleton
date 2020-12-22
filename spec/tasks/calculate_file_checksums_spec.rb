# frozen_string_literal: true

RSpec.describe 'Rake app:calculate_file_checksums' do
  include_context 'rake'

  it 'invokes with invalid number of times' do
    expect { subject.invoke ' !' }.to raise_error(ArgumentError, /\bInvalid .*\bInteger\b/i)
  end

  it 'invokes to calculate file checksums' do
    expect(o = UserFile.create(user_id: 1, name: '!', size: 5)).to be_truthy
    expect(File.write(FileUtils.ensure_dir_exists(path = o.real_file_path), 'hello')).to be_truthy

    expect { subject.invoke ' 5' }.to output(/^Checksum of user files \[.*\b#{o.id}.*\] was calculated/).to_stdout

    expect(o.reload).to have_attributes(checksum: '2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824', delete: be_truthy)
    expect(File.unlink(path)).to be_truthy
  end
end
