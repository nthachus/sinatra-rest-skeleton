# frozen_string_literal: true

module Skeleton
  class BaseService
    def initialize(app)
      # @type [Application]
      @app = app
      # @type [Logger]
      @logger = app.logger
      # @type [OpenStruct]
      @settings = app.settings
    end
  end

  # Services registration
  class Application < Sinatra::Base
    # @param [Class] klass
    def self.register_service(klass)
      return if klass.superclass != BaseService

      name = klass.name.demodulize.underscore
      var_name = "@#{name}".to_sym

      define_method name.to_sym do
        instance_variable_defined?(var_name) ? instance_variable_get(var_name) : instance_variable_set(var_name, klass.new(self))
      end
    end
  end
end
