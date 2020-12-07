# frozen_string_literal: true

RSpec.describe AuthenticationController do
  before :all do
    set_app described_class
  end

  it 'logins with non-exist user' do
    post '/login', '{"username":"!","password":"-"}', 'CONTENT_TYPE' => @app.mime_type(:json)
    expect(last_response).to be_bad_request
    expect(last_response.content_type).to match(/\b#{@app.default_encoding}$/)
    expect(last_response.body).to match(/"error":"Invalid username or password.","extra":"Couldn't find/)
  end

  it 'logins with incorrect user-password' do
    post '/login', '{"username":"ssl","password":"-"}', 'CONTENT_TYPE' => @app.mime_type(:json)
    expect(last_response).to be_bad_request
    expect(last_response.body).to match(/"error":"Invalid username or password.","extra":"Bad credentials/)
  end

  it 'logins by username successfully' do
    post '/login', '{"username":"ssl","password":"1234"}', 'CONTENT_TYPE' => @app.mime_type(:json)
    expect(last_response).to be_ok
    expect(last_response.body).to match(/^{"jwt":"[^"]+"}$/)
  end

  it 'logins by email successfully' do
    post '/login', '{"username":"ssl@skeleton.xx","password":"1234"}', 'CONTENT_TYPE' => @app.mime_type(:json)
    expect(last_response).to be_ok
    expect(last_response.body).to match(/^{"jwt":"[^"]+"}$/)
  end
end
