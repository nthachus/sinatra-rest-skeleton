# frozen_string_literal: true

RSpec.describe ApplicationController do
  before :all do
    set_app described_class
  end

  it 'should return welcome message' do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.content_type).to eq("#{@app.mime_type(:json)};charset=#{@app.default_encoding}")
    expect(last_response.body).to eq('"Rest-API skeleton"')
  end

  it 'should support favicon static file' do
    get '/favicon.ico'
    expect(last_response).to be_ok
    expect(last_response.content_type).to eq(@app.mime_type(:ico))
    expect(last_response.body).to be_empty
  end
end
