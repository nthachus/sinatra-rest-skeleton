# frozen_string_literal: true

namespace :app do
  desc 'Determine type and encoding of user files.'

  # rake "app:identify_file_types[5]"
  task :identify_file_types, [:times] do |_, args|
    ts = Time.now

    cnt = []
    Integer(args[:times] || 3).times do
      file = UserFile.find_by media_type: nil

      if file&.update_columns(media_type: '') # lock
        mime, charset = FileHelpers.identify_type file.real_file_path

        cnt << file.id if mime && file.update_columns(media_type: mime, encoding: charset)
      end

      sleep 1
    end

    # DEBUG
    puts "Type of user files #{cnt} was detected in: #{Time.now - ts}s" unless cnt.empty?
  end
end
