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
  { name: 'Kite Shield', weapon_type: 'Off Hand', cost: 4 },
  { name: 'Buckler', weapon_type: 'Off Hand', cost: 3 },
  { name: 'Cloak', weapon_type: 'Off Hand', cost: 3 },
  { name: 'Dagger', weapon_type: 'Off Hand', cost: 2 },
  { name: 'Kitchen pot/pan', weapon_type: 'Off Hand', cost: 2 },
  { name: 'Rubber Chicken', weapon_type: 'Off Hand', cost: 1 },
  { name: 'Cardboard box', weapon_type: 'Off Hand', cost: 1 },
  { name: 'Rope', weapon_type: 'Off Hand', cost: 1 }
]

if Weapon.count > 0
  puts "Weapons already exist, skipping weapon creation"
else
  weapons_data.each do |weapon_data|
    Weapon.create!(weapon_data)
  end
  puts "#{Weapon.count} weapons created"
end

# Create sample fighters
clubs = [ 'Southern Cross Swords', 'Auckland Sword & Shield', 'Ironfolk Combat', 'Whangarei Medieval Combat Club', 'Canterbury Historical Fencing Club', 'Waikato Duellists Society' ]

response = nil
while response != 'y' && response != 'n'
  puts "Would you like to create randomized fighters? (y/n) "
  response = gets.chomp.downcase
end

if response == 'y'
  puts "How many fighters would you like to create? "
  gets.chomp.to_i.times do |i|
    Fighter.create!(
      name: Faker::Name.name,
      club: clubs.sample
    )
  end
else
  Fighter.create!(name: 'Jackson Bird', club: clubs[0])
  Fighter.create!(name: 'Josh Gilligan', club: clubs[0])
  Fighter.create!(name: 'Maxwell Arnott', club: clubs[0])
  Fighter.create!(name: 'Marc Bailie', club: clubs[0])
  # Fighter.create!(name: 'Tobias Goodwin', club: clubs[0])
  # Fighter.create!(name: 'Will Smart', club: clubs[4])
  # Fighter.create!(name: 'Josh Gummer', club: clubs[4])
  # Fighter.create!(name: 'Joshua Lowe', club: clubs[4])
  # Fighter.create!(name: 'Sam Spekreijse', club: clubs[4])
  # Fighter.create!(name: 'Charlie O\'Malley', club: clubs[4])
  # Fighter.create!(name: 'Evelyn Ann Lewis', club: clubs[4])
  # Fighter.create!(name: 'Christian Whyte', club: clubs[1])
  # Fighter.create!(name: 'Lincoln Rose', club: clubs[2])
  # Fighter.create!(name: 'Atreyu Norman', club: clubs[2])
  # Fighter.create!(name: 'Liam Shaw', club: clubs[3])
  # Fighter.create!(name: 'Jonothon Grose', club: clubs[5])
end
puts "#{Fighter.count} fighters created"
