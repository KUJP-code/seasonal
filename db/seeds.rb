# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).


5.times do |i|
  am = User.create(
    ja_first_name: Faker::Name.first_name,
    ja_family_name: Faker::Name.last_name,
    katakana_name: Faker::Name.name.kana,
    en_name: "B'rett-Tan ner",
    email: Faker::Internet.unique.email,
    password: Faker::Internet.password(min_length: 10),
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number,
    role: :area_manager    
  )

  area = am.managed_areas.create(
    name: Faker::Address.city
  )

  sm = User.create(
    ja_first_name: Faker::Name.first_name,
    ja_family_name: Faker::Name.last_name,
    katakana_name: Faker::Name.name.kana,
    en_name: "B'rett-Tan ner",
    email: Faker::Internet.unique.email,
    password: Faker::Internet.password(min_length: 10),
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number,
    role: :school_manager   
  )

  school = sm.managed_schools.create(
    name: Faker::Address.city,
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number,
    area: area
  )

  school.users.create([
    {
    ja_first_name: Faker::Name.first_name,
    ja_family_name: Faker::Name.last_name,
    katakana_name: Faker::Name.name.kana,
    en_name: "B'rett-Tan ner",
    email: Faker::Internet.unique.email,
    password: Faker::Internet.password(min_length: 10),
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number,
    },
    {
    ja_first_name: Faker::Name.first_name,
    ja_family_name: Faker::Name.last_name,
    katakana_name: Faker::Name.name.kana,
    en_name: "B'rett-Tan ner",
    email: Faker::Internet.unique.email,
    password: Faker::Internet.password(min_length: 10),
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number,
    },
    {
    ja_first_name: Faker::Name.first_name,
    ja_family_name: Faker::Name.last_name,
    katakana_name: Faker::Name.name.kana,
    en_name: "B'rett-Tan ner",
    email: Faker::Internet.unique.email,
    password: Faker::Internet.password(min_length: 10),
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number,
    }
  ])

  school.users.customers.each do |customer|
    customer.children.create(
        ja_first_name: Faker::Name.first_name,
        ja_family_name: Faker::Name.last_name,
        katakana_name: Faker::Name.name.kana,
    en_name: "B'rett-Tan ner",
        birthday: Faker::Date.birthday(min_age: 2, max_age: 13),
        ssid: i,
        ele_school_name: Faker::GreekPhilosophers.name,
        post_photos: true,
        allergies: 'peanuts',
        school: customer.school
      )
  end

  event = school.events.create(
    name: Faker::JapaneseMedia::StudioGhibli.movie,
    description: Faker::JapaneseMedia::StudioGhibli.quote,
    start_date: Faker::Time.forward(days: 5),
    end_date: Faker::Date.between(from: 10.days.from_now, to: 15.days.from_now)
  )

  event.time_slots.create([
    {
      name: Faker::Games::LeagueOfLegends.champion,
      start_time: Faker::Time.forward(days: 5),
      end_time: Faker::Date.between(from: 10.days.from_now, to: 15.days.from_now),
      description: Faker::Lorem.sentence(word_count: 10),
      cost: 8000,
      registration_deadline: 4.days.from_now
    },
    {
      name: Faker::Games::LeagueOfLegends.champion,
      start_time: Faker::Time.forward(days: 5),
      end_time: Faker::Date.between(from: 10.days.from_now, to: 15.days.from_now),
      description: Faker::Lorem.sentence(word_count: 10),
      cost: 8000,
      registration_deadline: 3.days.from_now
    }
  ])
end

puts 'Created 5 areas and their schools,
3 customers for each school,
1 child for each customer,
AMs/SMs for each area/school,
an event for each school and
2 time slots for each event'

TimeSlot.all.each do |slot|
  slot.options.create(name: Faker::Book.title, description: Faker::Lorem.sentence(word_count: 10), cost: 4000)
end

puts 'Created an option for each time slot'

TimeSlot.all.each do |slot|
  Child.all.each do |child|
    child.registrations.create!(registerable: slot, cost: slot.cost)
  end
end

puts 'Created a time slot registration for each child'

Option.all.each do |option|
  Child.all.each do |child|
    child.registrations.create!(registerable: option, cost: option.cost)
  end
end

puts 'Created an option registration for each child'

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

puts 'Created my test accounts'