# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

5.times do |i|
  am = User.create(
    email: Faker::Internet.unique.email,
    password: Faker::Internet.password(min_length: 10),
    role: :area_manager    
  )

  area = am.create_managed_area(
    name: Faker::Address.city
  )

  sm = User.create(
    email: Faker::Internet.unique.email,
    password: Faker::Internet.password(min_length: 10),
    role: :school_manager   
  )

  school = sm.create_managed_school(
    name: Faker::Address.city,
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number,
    area: area
  )

  school.users.create([
    {
      email: Faker::Internet.unique.email,
      password: Faker::Internet.password(min_length: 10)
    },
    {
      email: Faker::Internet.unique.email,
      password: Faker::Internet.password(min_length: 10)
    },
    {
      email: Faker::Internet.unique.email,
      password: Faker::Internet.password(min_length: 10)
    }
  ])

end

p 'Created 5 areas and their schools/3 customers/AMs/SMs'

User.create([
  {
    email: 'admin@gmail.com',
    password: 'adminadminadmin',
    role: :admin
  },
  {
    email: 'am@gmail.com',
    password: 'ampasswordampassword',
    role: :area_manager
  },
  {
    email: 'sm@gmail.com',
    password: 'smpasswordsmpassword',
    role: :school_manager
  },
  {
    email: 'customer@gmail.com',
    password: 'customerpassword',
    role: :customer
  }
])

p 'Created my test accounts'