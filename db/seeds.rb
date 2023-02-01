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
    phone: Faker::PhoneNumber.phone_number
  }
])

admin = User.admins.last
am = User.area_managers.last
sm = User.school_managers.last
customer = User.customers.last

puts 'Created my test accounts'

area = am.managed_areas.create!(name: "Kanagawa")

puts 'Gave AM an area to manage'


area.schools.create!([
  {
    name: "大倉山",
    address: "〒222-0032 神奈川県横浜市港北区大豆戸町80",
    phone: '0120378056'
  },
  {
    name: "武蔵小杉",
    address: "〒211-0016 神奈川県川崎市中原区市ノ坪232",
    phone: '0120378056'
  },
  {
    name: "溝の口",
    address: "〒213-0002 神奈川県川崎市高津区二子３丁目３３−20 カーサ・フォーチュナー",
    phone: '0120378056'
  }
])

School.first.managers << User.create!(
  email: 'yoshi@ku.jp',
  password: 'smpasswordsmpassword',
  ja_first_name: 'みの',
  ja_family_name: 'よし',
  katakana_name: 'ミノヨシ',
  en_name: 'Mino Yoshi',
  role: :school_manager,
  address: Faker::Address.full_address,
  phone: Faker::PhoneNumber.phone_number
)

School.find(2).managers << User.create!(
  email: 'marinara@ku.jp',
  password: 'smpasswordsmpassword',
  ja_first_name: 'まりなら',
  ja_family_name: 'よ',
  katakana_name: 'マリナらヨ',
  en_name: 'Marinara Yo',
  role: :school_manager,
  address: Faker::Address.full_address,
  phone: Faker::PhoneNumber.phone_number
)

School.last.managers << sm

puts 'Added 3 schools and gave each a manager'

School.all.each do |school|
  school.customers.create!([
    {
      ja_first_name: Faker::Name.first_name,
      ja_family_name: Faker::Name.last_name,
      katakana_name: Faker::Name.name.kana,
      en_name: %w[Timmy Sally Billy Sarah Viktoria Brett].sample,
      email: Faker::Internet.unique.email,
      password: Faker::Internet.password(min_length: 10),
      address: Faker::Address.full_address,
      phone: Faker::PhoneNumber.phone_number
    },
    {
      ja_first_name: Faker::Name.first_name,
      ja_family_name: Faker::Name.last_name,
      katakana_name: Faker::Name.name.kana,
      en_name: %w[Timmy Sally Billy Sarah Viktoria Brett].sample,
      email: Faker::Internet.unique.email,
      password: Faker::Internet.password(min_length: 10),
      address: Faker::Address.full_address,
      phone: Faker::PhoneNumber.phone_number
    }
  ])
end

School.last.users << customer

puts 'Added 2 Faker customers to each school, plus my test customer to the last one'

User.customers.each do |customer_user|
  customer_user.children.create!([
    {
      ja_first_name: Faker::Name.first_name,
      ja_family_name: Faker::Name.last_name,
      katakana_name: Faker::Name.name.kana,
      en_name: %w[Timmy Sally Billy Sarah Viktoria Brett].sample,
      birthday: Faker::Date.birthday(min_age: 2, max_age: 13),
      ssid: Faker::Number.unique.number,
      ele_school_name: Faker::GreekPhilosophers.name,
      post_photos: true,
      allergies: 'peanuts',
      level: 'kindy',
      category: 'external',
      school: customer_user.school
    },
    {
      ja_first_name: Faker::Name.first_name,
      ja_family_name: Faker::Name.last_name,
      katakana_name: Faker::Name.name.kana,
      en_name: %w[Timmy Sally Billy Sarah Viktoria Brett].sample,
      birthday: Faker::Date.birthday(min_age: 2, max_age: 13),
      ssid: Faker::Number.unique.number,
      ele_school_name: Faker::GreekPhilosophers.name,
      post_photos: true,
      allergies: 'peanuts',
      level: 'land_high',
      category: 'reservation',
      school: customer_user.school
    }
  ])
end

puts 'Gave each customer 2 children'

Child.create!(
  ja_first_name: Faker::Name.first_name,
  ja_family_name: Faker::Name.last_name,
  katakana_name: Faker::Name.name.kana,
  en_name: %w[Timmy Sally Billy Sarah Viktoria Brett].sample,
  birthday: 'Wed, 20 Feb 2020',
  ssid: 1,
  ele_school_name: Faker::GreekPhilosophers.name,
  post_photos: true,
  allergies: 'peanuts'
)

puts "Created an orphaned child to test adding parent's children with"

choco_descrip = 'Make chocolate, play chocolate related games and learn English!'

School.all.each do |school|
    school.events.create!([
      {
        name: 'Chocolate Day 2024',
        description: choco_descrip,
        start_date: 'February 18 2024',
        end_date: 'February 18 2024'
      },
      {
        name: 'Spring School 2023',
        description: 'See the sakura and celebrate spring with KU!',
        start_date: 'March 16 2023',
        end_date: 'April 4 2023'
      }
    ])
end

puts 'Created choco day and spring school at each school'

Event.where(name: 'Chocolate Day 2024').each do |event|
  event.time_slots.create!([
    {
      name: 'Chocolate Day 9am',
      start_time: '18 Feb 2024 09:00 JST +09:00',
      end_time: '18 Feb 2024 11:00 JST +09:00',
      description: choco_descrip,
      cost: 8000,
      registration_deadline: '16 Feb 2024'
    },
    {
      name: 'Chocolate Day 11am',
      start_time: '18 Feb 2024 11:00 JST +09:00',
      end_time: '18 Feb 2024 12:00 JST +09:00',
      description: choco_descrip,
      cost: 8000,
      registration_deadline: '16 Feb 2024'
    },
    {
      name: 'Chocolate Day 2pm',
      start_time: '18 Feb 2024 14:00 JST +09:00',
      end_time: '18 Feb 2024 16:00 JST +09:00',
      description: choco_descrip,
      cost: 8000,
      registration_deadline: '16 Feb 2024'
    },
    {
      name: 'Chocolate Day 4pm',
      start_time: '18 Feb 2024 16:00 JST +09:00',
      end_time: '18 Feb 2024 18:00 JST +09:00',
      description: choco_descrip,
      cost: 8000,
      registration_deadline: '16 Feb 2024'
    }
  ])
end

puts 'Created time slots for choco day'

Event.where(name: 'Chocolate Day 2024').each do |event|
  event.time_slots.each do |slot|
    slot.options.create!(
        name: 'Commemorative Badge',
        description: 'Remember all the fun you had with this shiny badge!',
        cost: 100
      )
  end
end

puts 'Created options for chocolate day'

Event.where(name: 'Spring School 2023').each do |event|
  event.time_slots.create!([
    {
      name: 'Paint a Puzzle',
      start_time: '16 Mar 2023 09:00 JST +09:00',
      end_time: '16 Mar 2023 13:00 JST +09:00',
      description: 'Paint your own jigsaw puzzle!',
      cost: 8000,
      registration_deadline: '14 Mar 2023'
    },
    {
      name: 'Paint a Puzzle PM',
      start_time: '16 Mar 2023 13:00 JST +09:00',
      end_time: '16 Mar 2023 18:00 JST +09:00',
      description: 'Continue the fun in the afternoon!',
      cost: 8000,
      registration_deadline: '14 Mar 2023'
    },
    {
      name: 'Butterfly Finger Puppet',
      start_time: '17 Mar 2023 9:00 JST +09:00',
      end_time: '17 Mar 2023 13:00 JST +09:00',
      description: 'Make a cute butterfly puppet to take home and enjoy!',
      cost: 8000,
      registration_deadline: '15 Mar 2023'
    },
    {
      name: 'Butterfly Finger Puppet PM',
      start_time: '17 Mar 2023 13:00 JST +09:00',
      end_time: '17 Mar 2023 18:00 JST +09:00',
      description: 'Continue the fun in the afternoon!',
      cost: 8000,
      registration_deadline: '15 Mar 2023'
    },
    {
      name: 'Magic Day',
      start_time: '20 Mar 2023 9:00 JST +09:00',
      end_time: '20 Mar 2023 13:00 JST +09:00',
      description: 'Learn magic tricks that will dazzle your family!',
      cost: 8000,
      registration_deadline: '18 Mar 2023'
    },
    {
      name: 'Magic Day PM',
      start_time: '20 Mar 2023 13:00 JST +09:00',
      end_time: '20 Mar 2023 18:00 JST +09:00',
      description: 'Continue the fun in the afternoon!',
      cost: 8000,
      registration_deadline: '18 Mar 2023'
    },
    {
      name: 'Vegetable Stamps',
      start_time: '22 Mar 2023 9:00 JST +09:00',
      end_time: '22 Mar 2023 13:00 JST +09:00',
      description: 'Create some beautiful (and healthy) artwork!',
      cost: 8000,
      registration_deadline: '20 Mar 2023'
    },
    {
      name: 'Vegetable Stamps PM',
      start_time: '22 Mar 2023 13:00 JST +09:00',
      end_time: '22 Mar 2023 18:00 JST +09:00',
      description: 'Continue the fun in the afternoon!',
      cost: 8000,
      registration_deadline: '20 Mar 2023'
    },
    {
      name: 'Spider Web Race',
      start_time: '23 Mar 2023 9:00 JST +09:00',
      end_time: '23 Mar 2023 13:00 JST +09:00',
      description: 'Race out of a sticky situation!',
      cost: 8000,
      registration_deadline: '21 Mar 2023'
    },
    {
      name: 'Spider Web Race PM',
      start_time: '23 Mar 2023 13:00 JST +09:00',
      end_time: '23 Mar 2023 18:00 JST +09:00',
      description: 'Race out of a sticky situation!',
      cost: 8000,
      registration_deadline: '21 Mar 2023'
    },
    {
      name: 'Easter Egg Craft',
      start_time: '24 Mar 2023 9:00 JST +09:00',
      end_time: '24 Mar 2023 13:00 JST +09:00',
      description: 'Create your own special Easter Egg! No eating though!',
      cost: 8000,
      registration_deadline: '22 Mar 2023'
    },
    {
      name: 'Easter Egg Craft PM',
      start_time: '24 Mar 2023 13:00 JST +09:00',
      end_time: '24 Mar 2023 18:00 JST +09:00',
      description: 'Create your own special Easter Egg! No eating though!',
      cost: 8000,
      registration_deadline: '22 Mar 2023'
    },
    {
      name: 'Cherry Blossom Picnic',
      start_time: '27 Mar 2023 9:00 JST +09:00',
      end_time: '27 Mar 2023 13:00 JST +09:00',
      description: 'Enjoy a nice picnic under the cherry blossoms!',
      cost: 8000,
      registration_deadline: '25 Mar 2023'
    },
    {
      name: 'Cherry Blossom Picnic PM',
      start_time: '27 Mar 2023 13:00 JST +09:00',
      end_time: '27 Mar 2023 18:00 JST +09:00',
      description: 'Enjoy a nice picnic under the cherry blossoms!',
      cost: 8000,
      registration_deadline: '25 Mar 2023'
    },
    {
      name: 'Cute Grass Head',
      start_time: '28 Mar 2023 9:00 JST +09:00',
      end_time: '28 Mar 2023 13:00 JST +09:00',
      description: "Make your own little friend, in case you're ever stranded on a deserted island!",
      cost: 8000,
      registration_deadline: '26 Mar 2023'
    },
    {
      name: 'Cute Grass Head PM',
      start_time: '28 Mar 2023 13:00 JST +09:00',
      end_time: '28 Mar 2023 18:00 JST +09:00',
      description: "Make your own little friend, in case you're ever stranded on a deserted island!",
      cost: 8000,
      registration_deadline: '26 Mar 2023'
    },
    {
      name: 'Photo Frame',
      start_time: '29 Mar 2023 9:00 JST +09:00',
      end_time: '29 Mar 2023 13:00 JST +09:00',
      description: 'Make a special photo frame to store your most precious memories!',
      cost: 8000,
      registration_deadline: '27 Mar 2023'
    },
    {
      name: 'Photo Frame PM',
      start_time: '29 Mar 2023 13:00 JST +09:00',
      end_time: '29 Mar 2023 18:00 JST +09:00',
      description: 'Make a special photo frame to store your most precious memories!',
      cost: 8000,
      registration_deadline: '27 Mar 2023'
    },
    {
      name: 'Marble Pencil Holder',
      start_time: '30 Mar 2023 9:00 JST +09:00',
      end_time: '30 Mar 2023 13:00 JST +09:00',
      description: "Don't like holding pencils? Make something to do it for you!",
      cost: 8000,
      registration_deadline: '28 Mar 2023'
    },
    {
      name: 'Marble Pencil Holder PM',
      start_time: '30 Mar 2023 13:00 JST +09:00',
      end_time: '30 Mar 2023 18:00 JST +09:00',
      description: "Don't like holding pencils? Make something to do it for you!",
      cost: 8000,
      registration_deadline: '28 Mar 2023'
    },
    {
      name: 'Spring Terrarium',
      start_time: '31 Mar 2023 9:00 JST +09:00',
      end_time: '31 Mar 2023 13:00 JST +09:00',
      description: 'Create your own personal ecosystem to rule over!',
      cost: 8000,
      registration_deadline: '29 Mar 2023'
    },
    {
      name: 'Spring Terrarium PM',
      start_time: '31 Mar 2023 13:00 JST +09:00',
      end_time: '31 Mar 2023 18:00 JST +09:00',
      description: 'Create your own personal ecosystem to rule over!',
      cost: 8000,
      registration_deadline: '29 Mar 2023'
    },
    {
      name: 'Ninja Master',
      start_time: '3 Apr 2023 9:00 JST +09:00',
      end_time: '3 Apr 2023 13:00 JST +09:00',
      description: 'Become a ninja master!',
      cost: 8000,
      registration_deadline: '1 Apr 2023'
    },
    {
      name: 'Ninja Master PM',
      start_time: '3 Apr 2023 13:00 JST +09:00',
      end_time: '3 Apr 2023 18:00 JST +09:00',
      description: 'Become a ninja master!',
      cost: 8000,
      registration_deadline: '1 Apr 2023'
    },
    {
      name: 'DIY Tic-Tac-Toe',
      start_time: '4 Apr 2023 9:00 JST +09:00',
      end_time: '4 Apr 2023 13:00 JST +09:00',
      description: 'Make a game, then play it!',
      cost: 8000,
      registration_deadline: '2 Apr 2023'
    },
    {
      name: 'DIY Tic-Tac-Toe PM',
      start_time: '4 Apr 2023 13:00 JST +09:00',
      end_time: '4 Apr 2023 18:00 JST +09:00',
      description: 'Make a game, then play it!',
      cost: 8000,
      registration_deadline: '2 Apr 2023'
    },
    {
      name: 'Colorful Sand Art',
      start_time: '5 Apr 2023 9:00 JST +09:00',
      end_time: '5 Apr 2023 13:00 JST +09:00',
      description: 'Create art with a wave of nostalgia!',
      cost: 8000,
      registration_deadline: '3 Apr 2023'
    },
    {
      name: 'Colorful Sand Art PM',
      start_time: '5 Apr 2023 13:00 JST +09:00',
      end_time: '5 Apr 2023 18:00 JST +09:00',
      description: 'Create art with a wave of nostalgia!',
      cost: 8000,
      registration_deadline: '3 Apr 2023'
    }
  ])
end

puts 'Created time slots for spring school'


Event.where(name: 'Spring School 2023').each do |event|
  event.time_slots.each do |slot|
    slot.options.create!([
      {
        name: 'Meal',
        description: 'Top up on energy through the day!',
        cost: 100
      },
      {
        name: 'Arrive 30min early',
        description: 'Be at KU longer, for even more fun!',
        cost: 100
      },
      {
        name: 'Arrive 1hr early',
        description: 'Be at KU longer, for even more fun!',
        cost: 100
      },
      {
        name: 'Leave 30min late',
        description: 'Be at KU longer, for even more fun!',
        cost: 100
      },
      {
        name: 'Leave 1hr late',
        description: 'Be at KU longer, for even more fun!',
        cost: 100
      },
      ])
  end
end

puts 'Created options for spring school'

School.all.each do |school|
  school.time_slots.each do |slot|
    school.children.each do |child|
      child.registrations.create!(registerable: slot, cost: slot.cost)
    end
  end
end

puts 'Registered children for each time slot at each event at their school'

TimeSlot.all.each do |slot|
  Child.where.not(school: slot.school).order('RANDOM()').first.registrations.create(registerable: slot, cost: slot.cost)
end

puts 'Registered a child from a different school for each time slot'

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

# Event.all.each do |event|
#   event.registrations.last.adjustments.create!(
#     change: -3000,
#     reason: 'testing adjustments from seed file'    
#   )
# end

# puts 'Applied an adjustment to the latest registration for each event'

# TimeSlot.all.each do |slot|
#   slot.coupons.create(
#     code: Faker::Code.asin,
#     name: Faker::Games::LeagueOfLegends.champion,
#     description: Faker::Games::LeagueOfLegends.quote,
#     discount: 0.33,
#     combinable: false
#   )
# end

# puts 'Added a coupon for each time slot'