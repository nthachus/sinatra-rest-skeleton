# frozen_string_literal: true

namespace :app do
  desc 'Calculate user file checksums and write to the database.'

  # rake "app:calculate_file_checksums[5]"
  task :calculate_file_checksums, [:times] do |_, args|
    ts = Time.now

    cnt = []
    Integer(args[:times] || 3).times do
      file = UserFile.where(UserFile.arel_table[:size].gt(0)).find_by checksum: nil
      break unless file&.update_columns(checksum: '') # lock

      hash = FileHelpers.checksum file.real_file_path
      cnt << file.id if hash && file.update_columns(checksum: hash)
    end

    # DEBUG
    puts "Checksum of user files #{cnt} was calculated in: #{Time.now - ts}s"
  end
end
