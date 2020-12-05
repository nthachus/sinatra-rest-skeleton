# frozen_string_literal: true

class UserController < Skeleton::Application
  # Route prefix
  map '/user'

  get '/', authorize: [] do
    json current_user.as_json(methods: :session)
  end

  get '/list', authorize: [Constants::ROLE_ADMIN] do
    # list = user_service.list
    # json list.as_json(include: :user)
    not_implemented
  end
end
