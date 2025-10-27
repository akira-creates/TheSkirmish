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
User.create!(
  email: 'admin@tournament.local',
  password: 'password',
  password_confirmation: 'password',
  admin: true
)

puts "Admin user created: admin@tournament.local / password"

# Create weapons
weapons_data = [
  { name: 'Longsword', weapon_type: 'Two Handed' },
  { name: 'Arming Sword', weapon_type: 'Main Hand' },
  { name: 'Rapier', weapon_type: 'Main Hand' },
  { name: 'Saber', weapon_type: 'Main Hand' },
  { name: 'Spear', weapon_type: 'Two Handed' },
  { name: 'Messer', weapon_type: 'Main Hand' },
  { name: 'Dagger', weapon_type: 'Off Hand' },
  { name: 'Buckler', weapon_type: 'Off Hand' },
  { name: 'Cloak', weapon_type: 'Off Hand' },
  { name: 'Sidesword', weapon_type: 'Main Hand' }
]

weapons_data.each do |weapon_data|
  Weapon.create!(weapon_data)
end

puts "#{Weapon.count} weapons created"

# Create sample fighters
clubs = ['Steel City HEMA', 'Iron Gate Fencing', 'Dragon\'s Forge', 'Knight Errant School']

20.times do |i|
  Fighter.create!(
    name: Faker::Name.name,
    club: clubs.sample
  )
end

puts "#{Fighter.count} fighters created"
