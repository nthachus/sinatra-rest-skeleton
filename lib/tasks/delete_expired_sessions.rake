# frozen_string_literal: true

namespace :app do
  desc 'Delete all expired sessions from the database.'

  # rake "app:delete_expired_sessions[7200]"
  task :delete_expired_sessions, [:lifetime] do |_, args|
    ts = Time.now
    timeout = Integer(args[:lifetime] || Skeleton::Application.settings.jwt_lifetime)

    num = UserSession.where(UserSession.arel_table[:updated_at].lteq(ts - timeout)).delete_all
    # DEBUG
    puts "#{num} expired sessions was deleted in: #{Time.now - ts}s" if num.nonzero?
  end
end
