# frozen_string_literal: true

class AuthenticationController < Skeleton::Application
  # Route prefix
  map '/auth'

  post '/login', needs: %i[username password] do
    begin
      jwt = auth_service.login @params[:username], @params[:password]
      json jwt: jwt
    rescue ActiveRecord::RecordNotFound => e
      logger.warn e
      bad_request json_error(I18n.t('app.invalid_credentials'), e.to_s)
    end
  end
end
