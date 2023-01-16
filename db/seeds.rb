# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

User.create!([
  {
    email: 'admin@gmail.com',
    password: 'adminadminadmin',
    ja_first_name: Faker::Name.first_name,
    ja_family_name: Faker::Name.last_name,
    katakana_name: Faker::Name.name.kana,
    en_name: 'Brett Tanner',
    role: :admin,
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number
  },
  {
    email: 'am@gmail.com',
    password: 'ampasswordampassword',
    ja_first_name: Faker::Name.first_name,
    ja_family_name: Faker::Name.last_name,
    katakana_name: Faker::Name.name.kana,
    en_name: 'Workon Saturday',
    role: :area_manager,
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number
  },
  {
    email: 'sm@gmail.com',
    password: 'smpasswordsmpassword',
    ja_first_name: Faker::Name.first_name,
    ja_family_name: Faker::Name.last_name,
    katakana_name: Faker::Name.name.kana,
    en_name: 'Minoru Yoshida',
    role: :school_manager,
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number
  },
  {
    email: 'customer@gmail.com',
    password: 'customerpassword',
    ja_first_name: Faker::Name.first_name,
    ja_family_name: Faker::Name.last_name,
    katakana_name: Faker::Name.name.kana,
    en_name: 'Lucky Lastname',
    role: :customer,
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number,
    school: School.last
  }
])

admin = User.admins.last
am = User.area_managers.last
sm = User.school_managers.last
customer = User.customers.last

puts 'Created my test accounts'

area = am.managed_areas.create!(name: Faker::Address.city)

puts 'Gave AM an area to manage'

2.times do |i|
  area.schools.create!(
    name: Faker::Address.city,
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number
  )
end

School.all.each do |school|
  school.managers << sm
end

puts 'Added 2 schools and made SM the manager'

School.all.each do |school|
  2.times do |i|
    school.customers.create!(
      ja_first_name: Faker::Name.first_name,
      ja_family_name: Faker::Name.last_name,
      katakana_name: Faker::Name.name.kana,
      en_name: "B'rett-Tan ner",
      email: Faker::Internet.unique.email,
      password: Faker::Internet.password(min_length: 10),
      address: Faker::Address.full_address,
      phone: Faker::PhoneNumber.phone_number
    )
  end
end

School.last.users << customer

puts 'Added 2 Faker customers to each school, plus my test customer to the last one'

User.customers.each do |customer|
  2.times do |i|
    customer.children.create!(
      ja_first_name: Faker::Name.first_name,
      ja_family_name: Faker::Name.last_name,
      katakana_name: Faker::Name.name.kana,
      en_name: "B'rett-Tan ner",
      birthday: Faker::Date.birthday(min_age: 2, max_age: 13),
      ssid: Faker::Number.unique.number,
      ele_school_name: Faker::GreekPhilosophers.name,
      post_photos: true,
      allergies: 'peanuts',
      school: customer.school
    )
  end
end

puts 'Gave each customer 2 children'

School.all.each do |school|
  2.times do |i|
    school.events.create!(
      name: Faker::JapaneseMedia::StudioGhibli.movie,
      description: Faker::JapaneseMedia::StudioGhibli.quote,
      start_date: Faker::Time.forward(days: 5),
      end_date: Faker::Date.between(from: 10.days.from_now, to: 15.days.from_now)
    )
  end
end

puts 'Created 2 events at each school'

Event.all.each do |event|
  3.times do |i|
    event.time_slots.create(
      name: Faker::Games::LeagueOfLegends.champion,
      start_time: 5.days.from_now,
      end_time: Faker::Date.between(from: 10.days.from_now, to: 15.days.from_now),
      description: Faker::Lorem.sentence(word_count: 10),
      cost: 8000,
      registration_deadline: 2.days.from_now
    )
  end
end

puts 'Created 3 time slots for each event'

TimeSlot.all.each do |slot|
  6.times { |i| slot.options.create!(name: Faker::Book.title, description: Faker::Lorem.sentence(word_count: 10), cost: 4000) }
end

puts 'Created 6 options for each time slot'

School.all.each do |school|
  school.time_slots.each do |slot|
    school.children.each do |child|
      child.registrations.create!(registerable: slot, cost: slot.cost)
    end
  end
end

puts 'Registered children for each event at their school'

TimeSlot.all.each do |slot|
  Child.where.not(school: slot.school).order('RANDOM()').first.registrations.create(registerable: slot, cost: slot.cost)
end

puts 'Registered a child from a different school for each time slot'

Option.all.each do |option|
  Child.where(school: option.school).each do |child|
    child.registrations.create!(registerable: option, cost: option.cost)
  end
end

puts 'Registered each child for every option at their school'

Child.all.each do |child|
  child.create_regular_schedule(
    monday: [true, false].sample,
    tuesday: [true, false].sample,
    wednesday: [true, false].sample,
    thursday: [true, false].sample,
    friday: [true, false].sample
  )
end

puts 'Created a random regular schedule for each child'

Event.all.each do |event|
  event.registrations.last.adjustments.create!(
    change: -3000,
    reason: 'testing adjustments from seed file'    
  )
end

puts 'Applied an adjustment to the latest registration for each event'

TimeSlot.all.each do |slot|
  slot.coupons.create(
    code: Faker::Code.asin,
    name: Faker::Games::LeagueOfLegends.champion,
    description: Faker::Games::LeagueOfLegends.quote,
    discount: 0.33,
    combinable: false
  )
end

puts 'Added a coupon for each time slot'