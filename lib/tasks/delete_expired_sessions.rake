# frozen_string_literal: true

namespace :app do
  desc 'Delete all expired sessions from the database.'

  # rake "app:delete_expired_sessions[7200]"
  task :delete_expired_sessions, [:lifetime] do |_, args|
    ts = Time.now
    timeout = args[:lifetime]&.to_i || Skeleton::Application.jwt_lifetime

    num = UserSession.where('updated_at <= ?', ts - timeout).delete_all
    # DEBUG
    puts "#{num} expired sessions was deleted in: #{Time.now - ts}s"
  end
end
