# frozen_string_literal: true

# Set path to app that will be used to configure unicorn
@dir = File.expand_path(__dir__)

# Use at least one worker per core if you're on a dedicated server
worker_processes 4
working_directory @dir

# Nuke workers after 24 hours instead of 60 seconds (the default)
timeout 86_400

# Specify path to socket unicorn listens to,
# we will use this in our nginx.conf later
# listen "#{@dir}/tmp/sockets/unicorn.sock", backlog: 64 # number of clients
listen 3000, tcp_nopush: true

# Set process id path
pid "#{@dir}/tmp/pids/unicorn.pid"

# Set log file paths
stderr_path "#{@dir}/log/unicorn.stderr.log"
stdout_path "#{@dir}/log/unicorn.stdout.log"

# Combine Ruby 2.0.0+ with "preload_app true" for memory savings
preload_app true

# Chunk size for upload
client_body_buffer_size 4_194_304

before_fork do |_server, _worker|
  # Boot the application
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
end

after_fork do |_server, _worker|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
end
