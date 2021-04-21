# frozen_string_literal: true

RSpec.describe 'Rake app:identify_file_types' do
  include_context 'rake'

  before :all do
    FileUtils.touch Skeleton::Application::PID_FILE
  end

  it 'invokes with invalid number of times' do
    expect { subject.invoke ' !' }.to raise_error(ArgumentError, /\bInvalid .*\bInteger\b/i)
  end

  it 'invokes to detect file type by extension' do
    expect(o = UserFile.create(user_id: 1, name: '!.gz', size: -1)).to be_truthy
    expect { subject.invoke ' 2' }.to output(/^Type of user files \[.*\b#{o.id}.*\] was detected/).to_stdout
    expect(o.reload).to have_attributes(media_type: 'application/x-gzip', encoding: nil, delete: be_truthy)
  end

  # noinspection SpellCheckingInspection
  {
    binary: [24, 'R0lGODlhAQABAAAAACwAAAAAAQABAAAC', 'image/gif'],
    'UTF-8' => [12, 'ClJ1Ynnjgajjga8K'],
    'UTF-16BE' => [16, '/v8AIgBNAOkAbgBlAHIACg'],
    Big5: [19, 'DQpMQ0QvuXGkbLlxuPQgpOKlvg'],
    Shift_JIS: [18, 'DQqMdonmgUWN7IvGjneOpo+R']
  }.each do |charset, content|
    it "invokes to detect #{content[2] || charset} encoded file by content" do
      expect(file_content = Base64.decode64(content[1])).to have_attributes(size: content[0])
      expect(o = UserFile.create(user_id: 1, name: '!.c', size: file_content.size)).to be_truthy
      expect(File.write(FileUtils.ensure_dir_exists(path = o.real_file_path), file_content, mode: 'wb')).to be_truthy

      expect { subject.invoke '1' }.to output(/^Type of user files \[.*\b#{o.id}.*\] was detected/).to_stdout

      expect(File.unlink(path)).to be_truthy
      expect(o.reload).to have_attributes(media_type: content[2] || 'text/plain', encoding: match(/^#{charset}$/i), delete: be_truthy)
    end
  end
end
