# frozen_string_literal: true

require 'rack/urlmap'

module Skeleton
  # noinspection RubyClassVariableUsageInspection
  class Application < Sinatra::Base
    @@route_prefixes = {} # rubocop:disable Style/ClassVars

    def self.map(url)
      @@route_prefixes[url] = self
    end

    def self.new(*)
      self < Application ? super : Rack::URLMap.new(@@route_prefixes)
    end
  end
end
