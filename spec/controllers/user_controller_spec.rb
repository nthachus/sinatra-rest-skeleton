# frozen_string_literal: true

require_relative '../fixtures/jwt_for_users'

RSpec.describe UserController do
  before :all do
    set_app described_class
  end

  it 'gets the logged-in user info' do
    setup_auth_header Fixtures::SSL_USER_JWT
    get '/'
    expect(last_response).to be_ok
    expect(last_response.content_type).to match(/\b#{@app.default_encoding}$/)
    expect(last_response.body).to match(/"role":"user","username":"ssl","name":"SSL User",.*"session":{/)
  end

  it 'only admin can list users' do
    setup_auth_header Fixtures::SSL_USER_JWT
    get '/list'
    expect(last_response).to be_forbidden
    expect(last_response.content_type).to match(/\b#{@app.default_encoding}$/)
    expect(last_response.body).to eq('{"error":"Access is denied."}')
  end

  it 'list users by administrator' do
    setup_auth_header Fixtures::ADMIN_JWT
    get '/list'
    expect(last_response).to be_ok
    expect(last_response.content_type).to match(/\b#{@app.default_encoding}$/)
    expect(last_response.body).to match(/^\[{.*"role":"user",.*"sessions":\[{/) & match(/"role":"power"/) & match(/"role":"admin"/)
  end

  it 'list users by power user' do
    setup_auth_header Fixtures::POWER_USER_JWT
    get '/list'
    expect(last_response).to be_ok
    expect(last_response.body).to match(/^\[{.*"role":"user",.*"sessions":\[{/) & match(/"role":"power"/)
    expect(last_response.body).not_to match(/"role":"admin"/)
  end

  private

  def setup_auth_header(jwt)
    header 'Authorization', "Bearer #{jwt}"
  end
end
