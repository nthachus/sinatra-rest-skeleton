# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/vendor/'
  add_group 'Models', '/app/models/'
  add_group 'Controllers', '/app/controllers/'
  add_group 'Tasks', '/lib/tasks/'
  add_group 'Specs', '/spec/'
end

# Content of test helper starts here
ENV['RACK_ENV'] ||= 'test'
require_relative '../config/environment'

require 'rspec'
require 'sinatra/test_helpers'

# Requires supporting ruby files
Dir[File.expand_path('support/**/*.rb', __dir__)].sort.each(&method(:require))

RSpec.configure do |config|
  config.backtrace_exclusion_patterns << %r{vendor[\\/]}

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  # Automatically add metadata :type to specs based on their file location
  %i[controller helper model integration feature task].each do |type|
    config.define_derived_metadata(file_path: %r{spec[\\/]#{type}s?[\\/]}) { |metadata| metadata[:type] ||= type }
  end

  # Testing Sinatra with mixins
  config.include Sinatra::TestHelpers
end
