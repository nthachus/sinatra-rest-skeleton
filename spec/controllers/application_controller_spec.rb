# frozen_string_literal: true

RSpec.describe ApplicationController do
  before :all do
    set_app described_class
  end

  it 'prints welcome' do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.content_type).to eq("#{@app.mime_type(:json)};charset=#{@app.default_encoding}")
    expect(last_response.body).to eq('"Rest-API skeleton"')
  end

  it 'returns not-implemented error' do
    header 'Accept-Language', 'ja'
    get '/status'
    expect(last_response.status).to eq(501)
    expect(last_response.body).to eq('{"message":"機能は実装されない。"}')
  end

  it 'supports favicon static file' do
    get '/favicon.ico'
    expect(last_response).to be_ok
    expect(last_response.content_type).to eq(@app.mime_type(:ico))
    expect(last_response.body).to be_empty
  end
end
