# frozen_string_literal: true

RSpec.describe ApplicationController do
  before :all do
    set_app described_class
  end

  it 'prints welcome' do
    get '/'
    expect(last_response).to be_ok & have_attributes(cache_control: match(/\bno-cache\b/))
    expect(last_response.content_type).to eq("#{@app.mime_type(:json)};charset=#{@app.default_encoding}")
    expect(last_response.body).to eq('"Rest-API skeleton"')
  end

  it 'returns not-implemented error' do
    header 'Accept-Language', 'ja'
    get '/status'
    expect(last_response).to have_attributes(status: 501, cache_control: match(/\bno-cache\b/))
    expect(last_response.body).to eq('{"message":"機能は実装されない。"}')
  end

  it 'supports favicon static file' do
    get '/favicon.ico'
    expect(last_response).to be_ok & have_attributes(cache_control: be_falsey)
    expect(last_response.content_type).to eq(@app.mime_type(:ico))
    expect(last_response.body).to be_empty
  end
end
