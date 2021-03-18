# Sinatra Rest Skeleton

A boilerplate for **Sinatra** Restful-API applications using Rails structure.

## Dependencies

- `Ruby` 2.3+ with default gems: `json`, `rake`, `bundler`
- `PostgreSQL` 9.4+

## What is inside?

For Framework:

- Sinatra (v2.0.x)
- Sinatra Contrib (v2.0.x)
- Rack (v2) - Web-server Interface that Sinatra based on
- Rack Contrib (v2)

For Database:

- I18n (v1) - For Localization
- Active Support (v5.2.x) - Utility classes and Ruby extensions
- Active Record (v5.2.x) - ORM Framework
- Arel (latest) - Constructing SQL queries
- Postgres (v1)

For Testing:

- RSpec (v3)
- Rack Test (v1) - Testing API for Rack
- SimpleCov (v0.17) - Code coverage analysis tool

For Development:

- Pry (latest) - Runtime developer console for Debugging
- RuboCop (v0.79) - Code style checker
- Thin (v1) - Small & fast web-server

For Deployment:

- Unicorn (latest) - Rack HTTP server

Misc:

- BCrypt (v3.1.x) - For password hashing
- JWT (latest) - JSON Web Token
- Net::LDAP (latest) - LDAP client

## Features

- Auto-encode JSON responses with UTF-8
- Custom app settings using YAML file
- Localization with `Accept-Language` header
- Auto-reload code while running DEV server
- Handle errors with JSON responses
- Auto-parse JSON request body
- Provide simple needed parameters validation
- Disable client caching for JSON APIs
- Authentication & Authorization using JWT
- Role-based Authorization
- Provide API to renew JWT
- Authentication with SSL client certificate
- Authentication with AD/LDAP server
- Resumable upload using [tus protocol](https://tus.io/protocols/resumable-upload.html)
- Resumable download with [range requests](https://developer.mozilla.org/en-US/docs/Web/HTTP/Range_requests)
- Active Record DB seeding with environment seed files
- Support custom Rake tasks with `*.rake` files
- Unit-testing app controllers, models,... using RSpec

## Directory structure

```
$
├─ [app]
│  ├─ [controllers]
│  ├─ [helpers]
│  ├─ [models]        - Active Record model classes
│  └─ [services]      - Self-registered services
├─ [config]
│  ├─ [initializers]  - Sinatra app initializers: filters, extensions,...
│  ├─ [locales]       - Localization YAML files
│  ├─ application.rb  - Sinatra modular app
│  ├─ database.yml    - Database config for Active Record
│  ├─ environment.rb  - Initialize the application
│  └─ settings.yml    - App settings
├─ [db]
│  ├─ [migrate]       - Active Record DB migrations
│  ├─ [seeds]
│  └─ seeds.rb        - Active Record DB seeding
├─ [lib]
│  └─ [tasks]         - App Rake tasks (*.rake)
├─ [log]              - Unicorn log files
├─ [public]           - Serve static files
├─ [spec]
│  ├─ [controllers]
│  ├─ [fixtures]      - RSpec fixture files
│  ├─ [integration]
│  ├─ [models]
│  └─ spec_helper.rb  - RSpec prerequisite
├─ [storage]
├─ [tmp]
│  ├─ [cache]
│  ├─ [pids]    - Unicorn PID file
│  └─ [sockets] - Unicorn socket file
├─ [vendor]
├─ .rspec       - RSpec config file
├─ config.ru    - Rack app entry-point
├─ Rakefile     - Rake tasks entry-point
└─ unicorn.rb   - Unicorn config file
```

## Development

Install dependencies:

    $ bundle install --path vendor/bundle --no-cache

Code style checking:

    $ bundle exec rubocop

Initialize database:

    $ rake db:setup && rake db:seed RACK_ENV=test

Running unit tests:

    $ bundle exec rspec

Development server:

    $ bundle exec thin -t 86400 --threaded start

Then, navigate http://localhost:3000/ for verifying.

## Development using [Docker](https://www.docker.com)

Build and run Development server:

    $ docker-compose up -d db api-dev

Then, run `docker exec -it skeleton-api /bin/bash` for development console.\
**Refer** to [docker-compose.yml](docker-compose.yml) for more details.

Running Production server after the built:

    $ docker-compose up -d db api-prod

Navigate http://docker.lvh.me:3000/ for verifying (`docker.lvh.me` is the running docker-machine IP).\
**Refer** to [Dockerfile](Dockerfile) for deployment on [Amazon Linux 2](https://aws.amazon.com/amazon-linux-2/).

### Notes

- View the executed SQLs: `docker-compose logs db`
- Shutdown the Docker containers: `docker-compose down`

## License

The skeleton is available as open source under the terms of the [MIT License](LICENSE).
