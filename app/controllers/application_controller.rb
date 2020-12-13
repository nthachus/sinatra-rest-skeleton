# frozen_string_literal: true

class ApplicationController < Skeleton::Application
  # Route prefix
  map '/'
  enable :static

  get '/' do
    # noinspection RailsI18nInspection
    json I18n.t('app.welcome')
  end

  get '/status' do
    not_implemented
  end
end
