# frozen_string_literal: true

puts "-- seeding data file: #{File.basename(__FILE__)}"

# Users
UserSession.create! user_id: 1, key: 'admin-xx'

user = User.create! username: 'ssl', password: '1234', name: 'SSL User', email: 'ssl@skeleton.xx'
UserSession.create! user: user, key: 'ssl-xx'

user = User.create! username: 'power', password: '1234', role: Constants::Roles::POWER, name: 'Power User'
UserSession.create! user: user, key: 'power-xx'
