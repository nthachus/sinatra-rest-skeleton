# frozen_string_literal: true

require_relative '../fixtures/jwt_for_users'

RSpec.describe FileController do
  SAMPLE_FN = RUBY_PLATFORM =~ /mswin|mingw/ ? ['-/foo!.z', /="foo!\.z"/] : ['-/foo".z', /="foo\\"\.z"/]

  before :all do
    set_app described_class

    @file = UserFile.create! user_id: 2, name: SAMPLE_FN[0], size: 10, media_type: 'text/x-c'
    File.write FileUtils.ensure_dir_exists(@file.real_file_path), 'Hello Foo!'
  end

  after :all do
    File.unlink @file.real_file_path
    @file.delete
  end

  it 'headers for user-file downloads' do
    head download_api_path
    expect(last_response).to be_ok
    expect(last_response.headers).to include('Accept-Ranges' => 'bytes')
    expect(last_response.body).to be_empty
  end

  it 'downloads a non-modified user-file' do
    header 'If-Modified-Since', File.mtime(@file.real_file_path).httpdate
    get download_api_path
    expect(last_response).to have_attributes(status: 304)
    expect(last_response.body).to be_empty
  end

  it 'downloads user-file with invalid ranges' do
    header 'Range', 'bytes= 10- '
    get download_api_path
    expect(last_response).to have_attributes(status: 416, content_type: 'text/plain')
    expect(last_response.headers).to include('Content-Range' => 'bytes */10')
  end

  it 'downloads user-file without ranges' do
    get download_api_path
    expect(last_response).to be_ok & have_attributes(content_type: match(%r{^text/x-c\b}), content_length: 10)
    expect(last_response.headers).to include('Last-Modified' => be_truthy, 'Content-Disposition' => match(SAMPLE_FN[1]))
    expect(last_response.body).to eq('Hello Foo!')
  end

  it 'downloads user-file with single-part ranges' do
    header 'Range', 'bytes= -5 '
    get download_api_path
    expect(last_response).to have_attributes(status: 206, content_type: match(%r{^text/x-c\b}), content_length: 5)
    expect(last_response.headers).to \
      include('Last-Modified' => be_truthy, 'Content-Disposition' => match(SAMPLE_FN[1]), 'Content-Range' => 'bytes 5-9/10')
    expect(last_response.body).to eq(' Foo!')
  end

  it 'downloads user-file with multipart ranges' do
    header 'Range', 'bytes= 0-3 , 6- '
    get download_api_path
    expect(last_response).to have_attributes(status: 206, content_type: match(%r{^multipart/byteranges;}), content_length: 156)
    expect(last_response.headers).to include('Last-Modified', 'Content-Disposition' => match(SAMPLE_FN[1])) & exclude('Content-Range')
    expect(last_response.body).to match(%r{(\sContent-Type: text/x-c\s+Content-Range: bytes) 0-3/10\s+Hell\s+--.*\1 6-9/10\s+Foo!\s+--})
  end

  it 'downloads a non-exist user-file' do
    get download_api_path(Fixtures::ADMIN_JWT)
    expect(last_response).to be_not_found
    expect(last_response.content_type).to match(/\b#{@app.default_encoding}$/)
    expect(last_response.body).to eq('{"error":"Upload file not found."}')
  end

  it 'downloads a non-exist user-file path' do
    expect(@file.update_columns(name: "#{@file.name}-")).to be_truthy
    begin
      get download_api_path
      expect(last_response).to be_not_found
      expect(last_response.content_type).to match(/\b#{@app.default_encoding}$/)
      expect(last_response.body).to match(/"error":"Resource not found\.","extra":"No such file or directory\b/)
    ensure
      @file.name.chop!
    end
  end

  private

  def download_api_path(jwt = Fixtures::SSL_USER_JWT)
    "/#{@file.id}/download?token=#{URI.encode_www_form_component(jwt, @app.default_encoding)}"
  end
end
