# frozen_string_literal: true

RSpec.describe 'Error handling' do
  before :all do
    mock_app ApplicationController do
      get '/raise-error' do
        raise 'Runtime error.'
      end
    end
  end

  it 'should return not-found message for non-exist API' do
    get '/non-exist'
    expect(last_response).to be_not_found
    expect(last_response.body).to eq('{"error":"Resource not found."}')
  end

  it 'should return error message for exception API' do
    get '/raise-error'
    expect(last_response.status).to eq(500)
    expect(last_response.content_type).to match(/\b#{settings.default_encoding}$/)
    expect(last_response.body).to match(/"error":".*","extra":\[".*\bRuntime error\b.*\b#{File.basename(__FILE__)}:7:/)
  end
end
