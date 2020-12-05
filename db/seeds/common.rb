# frozen_string_literal: true

puts "-- seeding data file: #{File.basename(__FILE__)}"

# Users
User.create! username: 'admin', password: '1234', role: Constants::Roles::ADMIN, name: 'Administrator', email: 'admin@skeleton.xx'
