# frozen_string_literal: true

Dir[File.expand_path("seeds/{common,#{ActiveRecord::Tasks::DatabaseTasks.env}}.rb", __dir__)].each(&method(:load))
