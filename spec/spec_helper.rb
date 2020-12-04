# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/vendor/'
  add_group 'Models', '/app/models/'
  add_group 'Controllers', '/app/controllers/'
  add_group 'Specs', '/spec/'
end

# Content of test helper starts here
ENV['RACK_ENV'] ||= 'test'
require_relative '../config/environment'

require 'rspec'
require 'sinatra/test_helpers'

RSpec.configure do |config|
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  # Testing Sinatra with mixins
  config.include Sinatra::TestHelpers
end
