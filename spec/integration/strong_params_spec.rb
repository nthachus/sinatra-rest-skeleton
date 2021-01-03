# frozen_string_literal: true

RSpec.describe 'Strong Parameters' do
  before :all do
    set_app AuthenticationController
  end

  it 'raises error for empty body' do
    post '/login', '', 'CONTENT_TYPE' => @app.mime_type(:json)
    expect(last_response).to be_bad_request
    expect(last_response.content_type).to match(/\b#{@app.default_encoding}$/)
    expect(last_response.body).to eq('{"message":"Missing parameters: username, password"}')
  end

  it 'missing parameter names' do
    post '/login', '{"username":0}', 'CONTENT_TYPE' => @app.mime_type(:json)
    expect(last_response).to be_bad_request
    expect(last_response.body).to eq('{"message":"Missing parameters: password"}')
  end

  it 'needs non-empty parameters' do
    post '/login', '{"username":"","password":null}', 'CONTENT_TYPE' => @app.mime_type(:json)
    expect(last_response).to be_bad_request
    expect(last_response.body).to eq('{"message":"Missing parameters: username, password"}')
  end
end
