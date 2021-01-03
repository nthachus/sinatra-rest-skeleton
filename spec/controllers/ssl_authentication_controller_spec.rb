# frozen_string_literal: true

RSpec.describe 'SslAuthenticationController' do
  before :all do
    set_app AuthenticationController
  end

  it 'logins without SSL client' do
    post '/login_ssl'
    expect(last_response).to be_bad_request
    expect(last_response.content_type).to match(/\b#{@app.default_encoding}$/)
    expect(last_response.body).to eq('{"message":"Missing parameters: SSL Client"}')
  end

  it 'logins with bad SSL certificate' do
    setup_ssl_header nil, "-----BEGIN CERTIFICATE-----\nPQ==\n-----END CERTIFICATE-----\n"
    post '/login_ssl'
    expect(last_response).to be_bad_request
    expect(last_response.body).to match(/"message":"Invalid SSL client certificate.","details":"nested asn1 error/)
  end

  it 'logins with non-verifiable SSL client' do
    setup_ssl_header 'non_verifiable.crt'
    post '/login_ssl'
    expect(last_response).to be_bad_request
    expect(last_response.body).to match(/"message":"Invalid SSL client certificate.","details":"Verification failed/)
  end

  it 'logins with SSL client for non-exist user' do
    setup_ssl_header 'non_exist_user.crt'
    post '/login_ssl'
    expect(last_response).to be_bad_request
    expect(last_response.content_type).to match(/\b#{@app.default_encoding}$/)
    expect(last_response.body).to match(/"message":"Invalid SSL client certificate.","details":"User not found/)
  end

  it 'logins with SSL client successfully' do
    setup_ssl_header 'valid_email.crt'
    post '/login_ssl'
    expect(last_response).to be_ok
    expect(last_response.body).to match(/^{"jwt":"[^"]+"}$/)
  end

  private

  def setup_ssl_header(cert_file, cert = nil)
    cert ||= File.read File.expand_path("../fixtures/#{cert_file}", __dir__)
    header 'X-SSL-Client-Cert', URI.encode_www_form_component(cert, @app.default_encoding)
  end
end
