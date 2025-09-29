# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require "faker"

User.destroy_all
Car.destroy_all

owner  = User.create!(email: "owner@car.com",  password: "123456", name: "Owner")
renter = User.create!(email: "renter@car.com", password: "123456", name: "Renter")

cars = [
  { title: "Spotless Corolla - Your Perfect City Companion!",  brand: "Toyota",  model: "Corolla", year: 2019, seats: 5, price_per_day: 60, address: "1 Market St, Sydney NSW" },
  { title: "Sleek Mazda 3 - Drive in Style & Comfort!",         brand: "Mazda",   model: "3",       year: 2020, seats: 5,  price_per_day: 70, address: "200 George St, Sydney NSW" },
  { title: "Great Value Hyundai i30 - Melbourne Explorer Special!",     brand: "Hyundai", model: "i30",     year: 2018, seats: 5,    price_per_day: 50, address: "Collins St, Melbourne VIC" }
]

cars.each do |attrs|
  Car.create!(attrs.merge(user: owner, description: Faker::Vehicle.standard_specs.join(", ")))
end

puts "Seeded: #{User.count} users, #{Car.count} cars"
