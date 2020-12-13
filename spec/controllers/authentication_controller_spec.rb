# frozen_string_literal: true

RSpec.describe AuthenticationController do
  before :all do
    set_app described_class
    @jwt = []
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
    @jwt << last_response.body[8..-3]
  end

  it 'logins by email successfully' do
    post '/login', '{"username":"ssl@skeleton.xx","password":"1234"}', 'CONTENT_TYPE' => @app.mime_type(:json)
    expect(last_response).to be_ok
    expect(last_response.body).to match(/^{"jwt":"[^"]+"}$/)
    @jwt << last_response.body[8..-3]
  end

  it 'renews user token successfully' do
    skip 'Needs to login first' if @jwt.blank?
    header 'Authorization', "Bearer #{@jwt.last}"
    get '/token'
    expect(last_response).to be_ok
    expect(last_response.body).to include(@jwt.last)
  end

  it 'logins with existing LDAP user' do
    auth_server = @app.send(:ldap_servers).first
    auth_server['search_group'] = false
    begin
      post '/login', '{"username":"Administrator","password":"1234"}', 'CONTENT_TYPE' => @app.mime_type(:json)
      expect(last_response).to be_ok
      expect(last_response.body).to match(/^{"jwt":"[^"]+"}$/)
      expect(User.find(1).profile).not_to be_blank
    ensure
      auth_server.delete 'search_group'
    end
  end

  it 'logins with non-exist LDAP user' do
    post '/login', '{"username":"uid=ad1,ou=Users,dc=skeleton,dc=xx","password":"1234"}', 'CONTENT_TYPE' => @app.mime_type(:json)
    expect(last_response).to be_ok
    expect(last_response.body).to match(/^{"jwt":"[^"]+"}$/)
    expect(User.find_by!(username: 'ad1').profile).not_to be_blank
  end
end
