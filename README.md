# Sinatra Rest Skeleton

A boilerplate for **Sinatra** Restful-API applications using Rails structure.

## Dependencies

- `Ruby` 2.3+ with default gems: `json`, `rake`, `bundler`
- `PostgreSQL` 9.4+

## What is inside?

For Framework:
- Sinatra (v2.0.x)
- Sinatra Contrib (v2.0.x)
- Rack (v2)
- Rack Contrib (v2)

For Database:
- I18n (v1)
- Active Support (v5.2.x)
- Active Record (v5.2.x)
- Arel (latest)
- Postgres (v1)

For Testing:
- RSpec (v3)
- Rack Test (v1)
- SimpleCov (v0.17)

For Development:
- Pry (latest)
- RuboCop (v0.79)
- Thin (v1)
- Unicorn (latest)

Misc:
- BCrypt (v3.1.x)
- JWT (latest)
- Net::LDAP (latest)

## Features


## Directory structure

```bash
$
├─ [app]
│  ├─ [controllers]
│  ├─ [helpers]
│  ├─ [models]
│  └─ [services]
├─ [config]
│  ├─ [initializers]
│  ├─ [locales]
│  ├─ application.rb
│  ├─ database.yml
│  └─ settings.yml
├─ [db]
│  ├─ [migrate]
│  ├─ [seeds]
│  └─ seeds.rb
├─ [lib]
│  └─ [tasks]
├─ [log]
├─ [public]
├─ [spec]
│  ├─ [controllers]
│  ├─ [fixtures]
│  ├─ [integration]
│  ├─ [models]
│  └─ spec_helper.rb
├─ [storage]
├─ [tmp]
│  ├─ [cache]
│  ├─ [pids]
│  └─ [sockets]
├─ [vendor]
├─ .rspec
├─ config.ru
├─ Rakefile
└─ unicorn.rb
```

## Development
