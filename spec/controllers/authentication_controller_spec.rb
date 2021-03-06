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
    expect(last_response.body).to match(/"message":"Invalid username or password.","details":"Couldn't find/)
  end

  it 'logins with incorrect user-password' do
    post '/login', '{"username":"ssl","password":"-"}', 'CONTENT_TYPE' => @app.mime_type(:json)
    expect(last_response).to be_bad_request
    expect(last_response.body).to match(/"message":"Invalid username or password.","details":"Bad credentials/)
  end

  JWT_RES_PATTERN = /^{"jwt":"[^"]+"}$/.freeze

  it 'logins by username successfully' do
    post '/login', '{"username":"ssl","password":"1234"}', 'CONTENT_TYPE' => @app.mime_type(:json)
    expect(last_response).to be_ok
    expect(last_response.body).to match(JWT_RES_PATTERN)
    @jwt << last_response.body[8..-3]
  end

  it 'logins by email successfully' do
    post '/login', '{"username":"ssl@skeleton.xx","password":"1234"}', 'CONTENT_TYPE' => @app.mime_type(:json)
    expect(last_response).to be_ok
    expect(last_response.body).to match(JWT_RES_PATTERN)
    @jwt << last_response.body[8..-3]
  end

  { search_group: false, group_search_filter: '(member=%u)' }.each do |ldap_cfg, cfg_value|
    it "logins with existing LDAP user for #{ldap_cfg}" do
      auth_server = @app.send(:ldap_servers).first.tap { |ldap_server| ldap_server[ldap_cfg] = cfg_value }
      begin
        post '/login', '{"username":"Administrator","password":"1234"}', 'CONTENT_TYPE' => @app.mime_type(:json)
        expect(last_response).to be_ok
        expect(last_response.body).to match(JWT_RES_PATTERN)
        expect(User.find(1)).to have_attributes(profile: be_present)
      ensure
        auth_server.delete ldap_cfg
      end
    end
  end

  it 'logins with non-exist LDAP user' do
    expect(User.find_by(username: 'ad1')).to be_falsey
    post '/login', '{"username":"uid=ad1,ou=Users,dc=skeleton,dc=xx","password":"1234"}', 'CONTENT_TYPE' => @app.mime_type(:json)
    expect(last_response).to be_ok
    expect(last_response.body).to match(JWT_RES_PATTERN)
    expect(User.find_by(username: 'ad1')).to be_truthy & have_attributes(profile: be_present, delete: be_truthy)
  end

  it 'renews user token successfully' do
    skip 'needs to login first' if @jwt.blank?
    header 'Authorization', "Bearer #{@jwt.last}"
    get '/token'
    expect(last_response).to be_ok
    expect(last_response.body).to match(JWT_RES_PATTERN)
    expect(JWT.decode(last_response.body[8..-3], nil, false).first).to include('jti' => JWT.decode(@jwt.last, nil, false).first['jti'])
  end
end
