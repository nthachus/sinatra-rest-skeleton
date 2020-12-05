# frozen_string_literal: true

puts "-- seeding data file: #{File.basename(__FILE__)}"

# Users
user = User.create! username: 'ssl', password: '1234', name: 'SSL User', email: 'ssl@skeleton.xx'
UserSession.create! user: user, key: 'ssl-xx'

UserSession.create! user_id: 1, key: 'admin-xx'
