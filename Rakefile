# frozen_string_literal: true

require_relative 'config/application'
require 'sinatra/activerecord/rake'

# Add your own .rake tasks in files placed in lib/tasks
Dir[File.expand_path('lib/tasks/*.rake', __dir__)].each(&method(:load))

# Type `rake -T` on your command line to see the available rake tasks
