# frozen_string_literal: true

RSpec.describe 'Core Extensions' do
  it 'executes a non-exist command' do
    expect { Process.run_command 'non-exist-1' }.to raise_error(Errno::ENOENT, /\b(No such file)\b/i)
  end

  it 'executes a failure command' do
    path = File.expand_path 'non-exist', __dir__
    expect { p FileHelpers.detect_charset(path) }.to raise_error(RuntimeError, /\b(Cannot open|No such) file\b/i)
  end

  it 'executes an invalid command' do
    path = File.expand_path 'non-exist', __dir__
    expect { p FileHelpers.detect_mime(path) }.to raise_error(RuntimeError, /\b(Cannot open)\b/i)
  end
end
