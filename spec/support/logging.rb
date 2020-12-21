# frozen_string_literal: true

module Sinatra
  module TestHelpers
    # Configure logging output to a file
    mattr_reader :log_file, instance_accessor: false do
      io = File.new File.expand_path('../../log/rspec.stderr.log', __dir__), 'a'
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
