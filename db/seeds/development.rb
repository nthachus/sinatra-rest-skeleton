# frozen_string_literal: true

puts "-- seeding data file: #{File.basename(__FILE__)}"

# Users
User.create! username: 'ssl', password: '1234', name: 'SSL User', email: 'ssl@skeleton.xx', created_by: 1, updated_by: 1
User.create! username: 'power', password: '1234', role: Constants::Roles::POWER, name: 'Power User', created_by: 1
