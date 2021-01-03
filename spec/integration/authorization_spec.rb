# frozen_string_literal: true

RSpec.describe 'Authorization' do
  before :all do
    set_app UserController
  end

  it 'authorizes without token' do
    get '/?token='
    expect(last_response).to be_unauthorized
    expect(last_response.content_type).to match(/\b#{@app.default_encoding}$/)
    expect(last_response.body).to eq('{"message":"A token must be passed."}')
  end

  it 'authorizes for non-supported scheme' do
    setup_auth_header '=', 'Basic'
    get '/'
    expect(last_response).to be_unauthorized
    expect(last_response.body).to match(/"message":"The token is invalid\.","details":\[".*: Nil JSON web token/)
  end

  # noinspection SpellCheckingInspection
  [
    ['invalid token', '.', 'Not enough[^"]* segments'],
    [
      'incorrect secret JWT',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjB9.xBi4uJAEX1EoMJCg77R5stQZmpnUhzrxok495kgQ_b8',
      'Signature verification raised'
    ],
    [
      'invalid JWT issuer',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiItIn0.kwQiFy9cSsS4OPWGagaMVznMYJzPqK5cYE13dXVohzE',
      'Invalid issuer'
    ],
    [
      'invalid JWT issued at',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJTa2VsZXRvbiIsImlhdCI6NDA3MDkwODgwMH0.CihyTf93NVQgEsnueKPfYTcZgqItZUB5mFbkchqp340',
      'Invalid iat'
    ],
    [
      'non-exist user',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJTa2VsZXRvbiIsInN1YiI6LTF9.pr7pGucfMbSdaeIinGaFTUnm4vHGV91wsoQXmo4gkb0',
      'User not found'
    ],
    [
      'invalid session ID',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJTa2VsZXRvbiIsInN1YiI6MSwianRpIjoiLSJ9.c4giAyI8V0hIrBtH9u4N8TgQy96qmPjatQW8-YZqk3E',
      'Session not found'
    ]
  ].each do |(name, jwt, expected)|
    it "authorizes with #{name}" do
      setup_auth_header jwt
      get '/'
      expect(last_response).to be_unauthorized
      expect(last_response.body).to match(/"message":"The token is invalid\.","details":\[".*: #{expected}/)
    end
  end

  it 'authorizes with an expired token' do
    # noinspection SpellCheckingInspection
    setup_auth_header 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MTQ3NjQ4MDB9.SelrnuDhP7lP1zqbLp3kSMSeA88DRJqzUQ7nS6dO_10'
    get '/'
    expect(last_response).to be_unauthorized
    expect(last_response.body).to match(/"message":"The token has expired\."/)
  end

  private

  def setup_auth_header(jwt, schema = 'Bearer')
    header 'Authorization', "#{schema} #{jwt}"
  end
end
