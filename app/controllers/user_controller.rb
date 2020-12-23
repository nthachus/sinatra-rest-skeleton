# frozen_string_literal: true

class UserController < Skeleton::Application
  # Route prefix
  map '/user'

  # @!method user_service
  #   @return [Skeleton::UserService]

  get '/', authorize: [] do
    json current_user.as_json(except: :password_digest, methods: :session)
  end

  get '/search', authorize: [Constants::Roles::ADMIN, Constants::Roles::POWER] do
    list = user_service.find_all
    json list.as_json(except: :password_digest, include: :sessions)
  end
end
