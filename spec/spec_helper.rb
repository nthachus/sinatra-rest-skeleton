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

# Configure logging output to a file
module Sinatra
  module TestHelpers
    mattr_reader :log_file, instance_accessor: false do
      io = File.new File.expand_path('../log/rspec.stderr.log', __dir__), 'a'
      io.sync = true
      ActiveRecord::Base.logger ||= ::Logger.new(io)
      io
    end

    class Session < Rack::Test::Session
      def global_env
        @global_env ||= { Rack::RACK_ERRORS => TestHelpers.log_file }
      end
    end
  end
end

RSpec.configure do |config|
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  # Testing Sinatra with mixins
  config.include Sinatra::TestHelpers
end
