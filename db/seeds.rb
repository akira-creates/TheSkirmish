# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# Create admin user
if User.count == 0 then
  User.create!(
    email: 'admin@tournament.local',
    password: 'password',
    password_confirmation: 'password',
    admin: true
  )
end

puts "Admin user created: admin@tournament.local / password"

# Create weapons
weapons_data = [
  # Main hand weapons
  { name: 'Rapier', weapon_type: 'Main Hand', cost: 4 },
  { name: 'Saber', weapon_type: 'Main Hand', cost: 3 },
  { name: 'Sidesword', weapon_type: 'Main Hand', cost: 3 },
  { name: 'Messer', weapon_type: 'Main Hand', cost: 2 },
  { name: 'Arming Sword', weapon_type: 'Main Hand', cost: 2 },

  # Off hand weapons
  { name: 'Kite Shield', weapon_type: 'Off Hand', cost: 3 },
  { name: 'Dagger', weapon_type: 'Off Hand', cost: 2 },
  { name: 'Buckler', weapon_type: 'Off Hand', cost: 2 },
  { name: 'Cloak', weapon_type: 'Off Hand', cost: 2 },
  { name: 'Rubber Chicken', weapon_type: 'Off Hand', cost: 1 },
  { name: 'Cardboard box', weapon_type: 'Off Hand', cost: 1 },
  { name: 'Kitchen pot/pan', weapon_type: 'Off Hand', cost: 1 },
  { name: 'Rope', weapon_type: 'Off Hand', cost: 1 }
]

weapons_data.each do |weapon_data|
  Weapon.create!(weapon_data)
end

puts "#{Weapon.count} weapons created"

# Create sample fighters
clubs = [ 'Southern Cross Swords' ]

puts "How many fighters would you like to create? "
gets.chomp.to_i.times do |i|
  Fighter.create!(
    name: Faker::Name.name,
    club: clubs.sample
  )
end

puts "#{Fighter.count} fighters created"
