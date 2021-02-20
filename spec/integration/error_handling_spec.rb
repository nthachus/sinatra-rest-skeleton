# frozen_string_literal: true

RSpec.describe 'Error Handling' do
  before :all do
    mock_app ApplicationController do
      get '/raise-error' do
        raise 'Runtime error.'
      end
    end
  end

  it 'handles not-found error' do
    get '/non-exist'
    expect(last_response).to be_not_found & have_attributes(cache_control: match(/\bno-cache\b/))
    expect(last_response.body).to eq('{"message":"Resource not found."}')
  end

  it 'handles uncaught exception' do
    get '/raise-error'
    expect(last_response).to have_attributes(status: 500, cache_control: match(/\bno-cache\b/))
    expect(last_response.content_type).to match(/\b#{settings.default_encoding}$/)
    expect(last_response.body).to match(/"message":".*","details":\[".*: Runtime error\.".*\b#{File.basename(__FILE__)}:7:/)
  end
end
