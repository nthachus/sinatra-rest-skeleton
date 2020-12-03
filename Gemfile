# frozen_string_literal: true

source 'https://rubygems.org'
ruby '~> 2.3'

# Sinatra framework
gem 'rack', '~> 2.0'
gem 'rack-contrib'
gem 'sinatra', '~> 2.0.5'
gem 'sinatra-contrib', '~> 2.0.5'
# gem 'sinatra-cross_origin'

# Use PostgreSQL as the database for ActiveRecord
gem 'activerecord', '~> 5.2.3'
gem 'bcrypt', '~> 3.1.7' # ActiveModel has_secure_password
gem 'i18n', '< 2'
gem 'pg', '< 2.0'
# gem 'rake'
gem 'sinatra-activerecord'

# JWT implementation
gem 'jwt'
gem 'net-ldap' # AD/LDAP client
# gem 'rest-client'

group :development do
  # Call 'binding.pry' anywhere in the code to stop execution and get a debugger console
  gem 'pry'
  gem 'rubocop', '< 0.80'
  gem 'thin', '< 2.0'
end

group :test do
  gem 'rack-test'
  gem 'rspec'
  gem 'simplecov'
end

group :production do
  gem 'unicorn', platforms: :ruby
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
