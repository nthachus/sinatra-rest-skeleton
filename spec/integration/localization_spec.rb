# frozen_string_literal: true

RSpec.describe 'Localization' do
  before :all do
    set_app Skeleton::Application
  end

  before :each do
    header 'Accept-Language', 'ja'
  end

  it 'uses default language for missing translation' do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to eq('"Rest-API skeleton"')
  end

  it 'prints not-found error in Japanese' do
    get '/non-exist'
    expect(last_response).to be_not_found
    expect(last_response.content_type).to match(/\b#{@app.default_encoding}$/)
    expect(last_response.body).to eq('{"error":"資源は見つけなかった。"}')
  end
end
