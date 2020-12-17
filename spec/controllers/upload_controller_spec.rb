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

  it 'uploads with existing filename' do
    header 'Upload-Metadata', 'name eHg='
    header 'Upload-Length', '-1'
    post '/'
    expect(last_response).to have_attributes(status: 409)
    expect(last_response.body).to eq('{"error":"The file already exists."}')
  end

  it 'uploads with invalid file modified-date' do
    header 'Upload-Metadata', ' name YeS4rdCv, size LTE=,, lastModified IQ='
    post '/'
    expect(last_response).to be_bad_request
    expect(last_response.body).to eq('{"error":"Invalid parameters: Metadata","extra":["Last modified is not a number"]}')
  end

  it 'uploads with the first chunk' do
    header 'Upload-Metadata', 'name YeS4rdCv, size MTI, , is_confidential'
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
    expect(last_response.headers).to \
      include('Upload-Offset' => '5') & include('Upload-Metadata' => 'isConfidential,size MTI=,name Li9h5Lit0K8=')
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
