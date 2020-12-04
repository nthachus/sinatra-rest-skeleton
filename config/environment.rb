# frozen_string_literal: true

require_relative 'application'

# Initialize the application
Dir[File.expand_path('initializers/*.rb', __dir__)].sort.each(&method(:require))

Dir[File.expand_path('../app/{services,controllers}/*.rb', __dir__)].each(&method(:require))
