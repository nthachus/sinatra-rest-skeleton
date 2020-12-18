# frozen_string_literal: true

require_relative '../fixtures/jwt_for_users'

RSpec.describe UploadController do
  before :all do
    set_app described_class
    @file_id = []
  end

  before :each do
    header 'Authorization', "Bearer #{Fixtures::SSL_USER_JWT}"
  end

  it 'options for tus protocol' do
    options '/'
    expect(last_response).to be_no_content
    expect(last_response.content_type).to be_nil
    expect(last_response.headers).to have_key('Tus-Resumable') & have_key('Tus-Extension') & have_key('Tus-Max-Size')
  end

  it 'uploads without metadata' do
    post '/'
    expect(last_response).to be_bad_request
    expect(last_response.content_type).to match(/\b#{@app.default_encoding}$/)
    expect(last_response.body).to eq('{"error":"Missing parameters: File name"}')
  end

  it 'uploads with empty metadata' do
    header 'Upload-Metadata', ' '
    post '/'
    expect(last_response).to be_bad_request
    expect(last_response.body).to eq('{"error":"Missing parameters: File name"}')
  end

  it 'uploads with invalid Base64-encoded metadata' do
    header 'Upload-Metadata', "\tFoo\n!="
    post '/'
    expect(last_response).to be_bad_request
    expect(last_response.body).to eq('{"error":"Invalid parameters: Metadata"}')
  end

  it 'uploads with empty filename in metadata' do
    header 'Upload-Metadata', " name \t,\n"
    post '/'
    expect(last_response).to be_bad_request
    expect(last_response.body).to eq('{"error":"Missing parameters: File name"}')
  end

  it 'uploads without file-size' do
    header 'Upload-Metadata', 'name YeS4rdCv'
    post '/'
    expect(last_response).to be_bad_request
    expect(last_response.body).to eq('{"error":"Missing parameters: File size"}')
  end

  it 'uploads with invalid file-size' do
    header 'Upload-Metadata', 'name YeS4rdCv'
    header 'Upload-Length', ' ! '
    post '/'
    expect(last_response).to be_bad_request
    expect(last_response.body).to eq('{"error":"Missing parameters: File size"}')
  end

  it 'uploads with file-size limit exceeded' do
    header 'Upload-Metadata', ' name YeS4rdCv, ,size NDE5NDMwNA'
    post '/'
    expect(last_response).to have_attributes(status: 413)
    expect(last_response.headers).to have_key('Tus-Resumable')
    expect(last_response.body).to eq('{"error":"The file size is too large."}')
  end

  it 'uploads with invalid file modified-date' do
    header 'Upload-Metadata', ' name YeS4rdCv, size LTE=,, lastModified IQ='
    post '/'
    expect(last_response).to be_bad_request
    expect(last_response.body).to eq('{"error":"Invalid parameters: Metadata","extra":["Last modified is not a number"]}')
  end

  it 'creates upload with the first chunk' do
    header 'Upload-Metadata', 'name Li4vYeS4rdCv, size MTI, , is_extra'
    post '/', 'hello', 'CONTENT_TYPE' => described_class::TUS_CONTENT_TYPE
    expect(last_response).to be_ok
    expect(last_response.body).to be_blank
    expect(last_response.headers).to include('Upload-Offset' => '5') & include('Location' => match(%r{/[0-9a-f]+$}))
    @file_id << last_response.headers['Location'].sub(%r{^.*/}, '')
  end

  it 'gets information of non-exist upload' do
    head "/#{SecureRandom.hex}"
    expect(last_response).to be_not_found
    expect(last_response.headers).to have_key('Tus-Resumable')
    expect(last_response.body).to be_blank
  end

  it 'gets information of the upload' do
    skip 'needs to upload first' if @file_id.blank?
    head "/#{@file_id.first}"
    expect(last_response).to be_ok
    expect(last_response.body).to be_blank
    expect(last_response.headers).to include('Upload-Offset' => '5') & include('Upload-Metadata' => 'isExtra,name YeS4rdCv,size MTI=')
  end

  it 'resumes a non-exist upload' do
    patch "/#{SecureRandom.hex}"
    expect(last_response).to be_not_found
    expect(last_response.headers).to have_key('Tus-Resumable')
    expect(last_response.body).to eq('{"error":"Upload file not found."}')
  end

  it 'resumes upload without offset' do
    skip 'needs to upload first' if @file_id.blank?
    patch "/#{@file_id.first}"
    expect(last_response).to be_bad_request
    expect(last_response.body).to eq('{"error":"Invalid parameters: Offset"}')
  end

  it 'resumes upload with invalid offset' do
    skip 'needs to upload first' if @file_id.blank?
    header 'Upload-Offset', ' ! '
    patch "/#{@file_id.first}"
    expect(last_response).to be_bad_request
    expect(last_response.body).to eq('{"error":"Invalid parameters: Offset"}')
  end

  it 'resumes upload with a negative offset' do
    skip 'needs to upload first' if @file_id.blank?
    header 'Upload-Offset', '-1'
    patch "/#{@file_id.first}"
    expect(last_response).to be_bad_request
    expect(last_response.body).to eq('{"error":"Invalid parameters: Offset"}')
  end

  it 'uploads the third chunk' do
    skip 'needs to upload first' if @file_id.blank?
    header 'Upload-Metadata', ' lastModified MTU1ODMwOTY0MzAxMg'
    header 'Upload-Offset', '7'
    patch "/#{@file_id.first}", 'or'
    expect(last_response).to be_no_content
    expect(last_response.headers).to have_key('Tus-Resumable') & include('Upload-Offset' => '9')
  end

  it 'uploads the second chunk' do
    skip 'needs to upload first' if @file_id.blank?
    header 'Upload-Offset', '5'
    patch "/#{@file_id.first}", ' w', 'CONTENT_TYPE' => described_class::TUS_CONTENT_TYPE
    expect(last_response).to be_no_content
    expect(last_response.headers).to have_key('Tus-Resumable') & include('Upload-Offset' => '7')
  end

  it 'uploads the last chunk' do
    skip 'needs to upload first' if @file_id.blank?
    header 'Upload-Metadata', ' size MTE , isExtra MA'
    header 'Upload-Offset', '9'
    patch "/#{@file_id.first}", 'ld'
    expect(last_response).to be_no_content
    expect(last_response.headers).to have_key('Tus-Resumable') & include('Upload-Offset' => '11')

    path = File.expand_path '../../storage/files/2/a中Я', __dir__
    expect(Pathname.new(path)).to be_file & have_attributes(size: 11, read: 'hello world', mtime: Time.at(1_558_309_643, 12_000.0))
  end

  it 'uploads with existing filename' do
    header 'Upload-Metadata', ' name YeS4rdCv'
    header 'Upload-Length', '-1'
    post '/'
    expect(last_response).to have_attributes(status: 409)
    expect(last_response.body).to eq('{"error":"The file already exists."}')
  end

  it 'deletes a non-exist upload' do
    delete "/#{SecureRandom.hex}"
    expect(last_response).to be_not_found
    expect(last_response.headers).to have_key('Tus-Resumable')
    expect(last_response.body).to eq('{"error":"Upload file not found."}')
  end

  it 'deletes upload by ID' do
    skip 'needs to upload first' if @file_id.blank?
    delete "/#{@file_id.first}"
    expect(last_response).to be_no_content
    expect(last_response.headers).to have_key('Tus-Resumable')
  end
end
