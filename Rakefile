# frozen_string_literal: true

require_relative 'config/application'
require 'sinatra/activerecord/rake'

# Add your own .rake tasks in files placed in lib/tasks
Dir[File.expand_path('lib/tasks/*.rake', __dir__)].each(&method(:load))

# Enable SQL logging in development mode
ActiveRecord::Base.logger ||= Logger.new(STDOUT) if !Sinatra::Base.production? && Rake.application.top_level_tasks.any? { |t| t =~ /^app:/ }

# Type `rake -T` on your command line to see the available rake tasks
