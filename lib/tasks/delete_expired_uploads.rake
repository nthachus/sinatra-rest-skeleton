# frozen_string_literal: true

namespace :app do
  desc 'Delete all expired uploads and obsoleted files.'

  # rake "app:delete_expired_uploads[7200]"
  task :delete_expired_uploads, [:lifetime] do |_, args|
    ts = Time.now
    # @type [OpenStruct]
    settings = Skeleton::Application

    timeout = Integer(args[:lifetime] || settings.jwt_lifetime)
    num = Upload.where(Upload.arel_table[:updated_at].lteq(ts - timeout)).delete_all

    cnt = 0
    Dir[File.join(File.expand_path(format(settings.upload_tmp_path, '*'), settings.root), '*')].each do |path|
      name = File.basename path
      cnt += File.unlink(path) if name =~ /^[0-9a-f]+$/ && File.file?(path) && !Upload.exists?(key: name)
    end

    # DEBUG
    puts "#{num} expired uploads / #{cnt} obsoleted files was deleted in: #{Time.now - ts}s" unless num.zero? && cnt.zero?
  end
end
