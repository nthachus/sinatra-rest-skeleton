# frozen_string_literal: true

RSpec.describe 'JSON Body Parser' do
  before :all do
    set_app Skeleton::Application
  end

  it 'should return error for invalid JSON body' do
    post '/login', '{foo:0,}', 'CONTENT_TYPE' => @app.mime_type(:json)
    expect(last_response).to be_bad_request
    expect(last_response.content_type).to match(/\b#{@app.default_encoding}$/)
    expect(last_response.body).to match(/"error":"Invalid JSON request\.","extra":".*{foo:/)
  end

  it 'should return error for non-supported JSON body' do
    post '/login', '"foo"', 'CONTENT_TYPE' => @app.mime_type(:json)
    expect(last_response).to be_bad_request
    expect(last_response.body).to match(/"error":"Invalid JSON request\.","extra":".*\\"foo\\":String\b/)
  end
end
