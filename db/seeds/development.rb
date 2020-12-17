# frozen_string_literal: true

puts "-- seeding data file: #{File.basename(__FILE__)}"

# Users
User.create! username: 'ssl', password: '1234', name: 'SSL User', email: 'ssl@skeleton.xx'
User.create! username: 'power', password: '1234', role: Constants::Roles::POWER, name: 'Power User'
