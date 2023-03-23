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
      email: Faker::Internet.unique.email,
      password: Faker::Internet.password(min_length: 10),
      address: Faker::Address.full_address,
      phone: Faker::PhoneNumber.phone_number
    },
    {
      ja_first_name: Faker::Name.first_name,
      ja_family_name: Faker::Name.last_name,
      katakana_name: Faker::Name.name.kana,
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
      allergies: true,
      allergy_details: 'peanuts',
      kindy: true,
      category: :external,
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
      allergies: true,
      allergy_details: 'peanuts',
      kindy: false,
      category: :reservation,
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
  allergies: true,
  allergy_details: 'peanuts'
)

puts "Created an orphaned child to test adding parent's children with"

PriceList.create!([
  {
    name: 'Spring Test',
    courses: {
      1 => 4_216,
      5 => 18_700,
      10 => 33_000,
      15 => 49_500,
      20 => 66_000,
      25 => 82_500,
      30 => 99_000
    }
  },
  {
    name: 'Spring Test',
    courses: {
      1 => 6_600,
      5 => 30_000,
      10 => 55_000,
      15 => 80_000,
      20 => 100_000,
      25 => 120_000,
      30 => 140_000
    }
  }
])

puts 'Created a member and non-member price list for testing'

choco_descrip = 'Make chocolate, play chocolate related games and learn English!'

School.all.each do |school|
    school.events.create!([
      {
        name: 'Chocolate Day 2024',
        description: choco_descrip,
        start_date: 'February 18 2051',
        end_date: 'February 18 2051',
        member_prices_id: 1,
        non_member_prices_id: 2
      },
      {
        name: 'Spring School 2023',
        description: 'See the sakura and celebrate spring with KU!',
        start_date: 'March 16 2050',
        end_date: 'April 4 2050',
        member_prices_id: 1,
        non_member_prices_id: 2
      }
    ])
end

puts 'Created choco day and spring school at each school'

Event.where(name: 'Chocolate Day 2024').each do |event|
  event.time_slots.create!([
    {
      name: 'Chocolate Day 9am',
      morning: true,
      start_time: '18 Feb 2051 09:00 JST +09:00',
      end_time: '18 Feb 2051 11:00 JST +09:00',
      description: choco_descrip,
      registration_deadline: '16 Feb 2051',
      category: :party
    },
    {
      name: 'Chocolate Day 11am',
      morning: true,
      start_time: '18 Feb 2051 11:00 JST +09:00',
      end_time: '18 Feb 2051 12:00 JST +09:00',
      description: choco_descrip,
      registration_deadline: '16 Feb 2051',
      category: :party
    },
    {
      name: 'Chocolate Day 2pm',
      morning: true,
      start_time: '18 Feb 2051 14:00 JST +09:00',
      end_time: '18 Feb 2051 16:00 JST +09:00',
      description: choco_descrip,
      registration_deadline: '16 Feb 2051',
      category: :party
    },
    {
      name: 'Chocolate Day 4pm',
      morning: true,
      start_time: '18 Feb 2051 16:00 JST +09:00',
      end_time: '18 Feb 2051 18:00 JST +09:00',
      description: choco_descrip,
      registration_deadline: '16 Feb 2051',
      category: :party
    }
  ])
  event.image.attach(io: File.open('app/assets/images/chocolate_day_2024.jpg'), filename: 'logo.jpg', content_type: 'image/jpg')
end

puts 'Created time slots for choco day, and added images to each event'

Event.where(name: 'Chocolate Day 2024').each do |event|
  event.time_slots.each do |slot|
    slot.options.create!(
        name: 'Commemorative Badge',
        description: 'Remember all the fun you had with this shiny badge!',
        cost: 100
      )
    slot.image.attach(io: File.open("app/assets/images/#{slot.name.downcase.gsub(' ', '_').gsub('_pm', '')}.jpg"), filename: 'logo.jpg', content_type: 'image/jpg')
  end
end

puts 'Created options for chocolate day, added images to time slots'

Event.where(name: 'Spring School 2023').each do |event|
  event.time_slots.create!([
    {
      name: 'Paint a Puzzle',
      morning: true,
      start_time: '16 Mar 2050 09:00 JST +09:00',
      end_time: '16 Mar 2050 13:00 JST +09:00',
      description: 'Paint your own jigsaw puzzle!',
      registration_deadline: '14 Mar 2050'
    },
    {
      name: 'Butterfly Finger Puppet',
      morning: true,
      start_time: '17 Mar 2050 9:00 JST +09:00',
      end_time: '17 Mar 2050 13:00 JST +09:00',
      description: 'Make a cute butterfly puppet to take home and enjoy!',
      registration_deadline: '15 Mar 2050'
    },
    {
      name: 'Magic Day',
      morning: true,
      start_time: '20 Mar 2050 9:00 JST +09:00',
      end_time: '20 Mar 2050 13:00 JST +09:00',
      description: 'Learn magic tricks that will dazzle your family!',
      registration_deadline: '18 Mar 2050'
    },
    {
      name: 'Vegetable Stamps',
      morning: true,
      start_time: '22 Mar 2050 9:00 JST +09:00',
      end_time: '22 Mar 2050 13:00 JST +09:00',
      description: 'Create some beautiful (and healthy) artwork!',
      registration_deadline: '20 Mar 2050'
    },
    {
      name: 'Spider Web Race',
      morning: true,
      start_time: '23 Mar 2050 9:00 JST +09:00',
      end_time: '23 Mar 2050 13:00 JST +09:00',
      description: 'Race out of a sticky situation!',
      registration_deadline: '21 Mar 2050'
    },
    {
      name: 'Easter Egg Craft',
      morning: true,
      start_time: '24 Mar 2050 9:00 JST +09:00',
      end_time: '24 Mar 2050 13:00 JST +09:00',
      description: 'Create your own special Easter Egg! No eating though!',
      registration_deadline: '22 Mar 2050'
    },
    {
      name: 'Banana Party & Banana Split',
      morning: true,
      start_time: '25 Mar 2050 9:00 JST +09:00',
      end_time: '25 Mar 2050 13:00 JST +09:00',
      description: 'Party like a banana then split!',
      registration_deadline: '22 Mar 2050',
      category: 'special'
    },
    {
      name: 'Cherry Blossom Picnic',
      morning: true,
      start_time: '27 Mar 2050 9:00 JST +09:00',
      end_time: '27 Mar 2050 13:00 JST +09:00',
      description: 'Enjoy a nice picnic under the cherry blossoms!',
      registration_deadline: '25 Mar 2050'
    },
    {
      name: 'Cute Grass Head',
      morning: true,
      start_time: '28 Mar 2050 9:00 JST +09:00',
      end_time: '28 Mar 2050 13:00 JST +09:00',
      description: "Make your own little friend, in case you're ever stranded on a deserted island!",
      registration_deadline: '26 Mar 2050'
    },
    {
      name: 'Photo Frame',
      morning: true,
      start_time: '29 Mar 2050 9:00 JST +09:00',
      end_time: '29 Mar 2050 13:00 JST +09:00',
      description: 'Make a special photo frame to store your most precious memories!',
      registration_deadline: '27 Mar 2050'
    },
    {
      name: 'Marble Pencil Holder',
      morning: true,
      start_time: '30 Mar 2050 9:00 JST +09:00',
      end_time: '30 Mar 2050 13:00 JST +09:00',
      description: "Don't like holding pencils? Make something to do it for you!",
      registration_deadline: '28 Mar 2050'
    },
    {
      name: 'Spring Terrarium',
      morning: true,
      start_time: '31 Mar 2050 9:00 JST +09:00',
      end_time: '31 Mar 2050 13:00 JST +09:00',
      description: 'Create your own personal ecosystem to rule over!',
      registration_deadline: '29 Mar 2050'
    },
    {
      name: 'Ninja Master',
      morning: true,
      start_time: '3 Apr 2050 9:00 JST +09:00',
      end_time: '3 Apr 2050 13:00 JST +09:00',
      description: 'Become a ninja master!',
      registration_deadline: '1 Apr 2050'
    },
    {
      name: 'DIY Tic-Tac-Toe',
      morning: true,
      start_time: '4 Apr 2050 9:00 JST +09:00',
      end_time: '4 Apr 2050 13:00 JST +09:00',
      description: 'Make a game, then play it!',
      registration_deadline: '2 Apr 2050'
    },
    {
      name: 'Colorful Sand Art',
      morning: true,
      start_time: '5 Apr 2050 9:00 JST +09:00',
      end_time: '5 Apr 2050 13:00 JST +09:00',
      description: 'Create art with a wave of nostalgia!',
      registration_deadline: '3 Apr 2050'
    }
  ])
  event.image.attach(io: File.open('app/assets/images/spring_school_2023.jpg'), filename: 'logo.jpg', content_type: 'image/jpg')
end

puts 'Created morning time slots for spring school, and added images to the events'

Event.where(name: 'Spring School 2023').each do |event|
  event.time_slots.create!([
    {
      name: 'Paint a Puzzle',
      morning_slot: TimeSlot.find_by(name: 'Paint a Puzzle', morning: true, event_id: event.id),
      start_time: '16 Mar 2050 13:00 JST +09:00',
      end_time: '16 Mar 2050 18:00 JST +09:00',
      description: 'Continue the fun in the afternoon!',
      registration_deadline: '14 Mar 2050'
    },
    {
      name: 'Butterfly Finger Puppet',
      morning_slot: TimeSlot.find_by(name: 'Butterfly Finger Puppet', morning: true, event_id: event.id),
      start_time: '17 Mar 2050 13:00 JST +09:00',
      end_time: '17 Mar 2050 18:00 JST +09:00',
      description: 'Continue the fun in the afternoon!',
      registration_deadline: '15 Mar 2050'
    },
    {
      name: 'Magic Day',
      morning_slot: TimeSlot.find_by(name: 'Magic Day', morning: true, event_id: event.id),
      start_time: '20 Mar 2050 13:00 JST +09:00',
      end_time: '20 Mar 2050 18:00 JST +09:00',
      description: 'Continue the fun in the afternoon!',
      registration_deadline: '18 Mar 2050'
    },
    {
      name: 'Vegetable Stamps',
      morning_slot: TimeSlot.find_by(name: 'Vegetable Stamps', morning: true, event_id: event.id),
      start_time: '22 Mar 2050 13:00 JST +09:00',
      end_time: '22 Mar 2050 18:00 JST +09:00',
      description: 'Continue the fun in the afternoon!',
      registration_deadline: '20 Mar 2050'
    },
    {
      name: 'Spider Web Race',
      morning_slot: TimeSlot.find_by(name: 'Spider Web Race', morning: true, event_id: event.id),
      start_time: '23 Mar 2050 13:00 JST +09:00',
      end_time: '23 Mar 2050 18:00 JST +09:00',
      description: 'Race out of a sticky situation!',
      registration_deadline: '21 Mar 2050'
    },
    {
      name: 'Easter Egg Craft',
      morning_slot: TimeSlot.find_by(name: 'Easter Egg Craft', morning: true, event_id: event.id),
      start_time: '24 Mar 2050 13:00 JST +09:00',
      end_time: '24 Mar 2050 18:00 JST +09:00',
      description: 'Create your own special Easter Egg! No eating though!',
      registration_deadline: '22 Mar 2050'
    },
    {
      name: 'Cherry Blossom Picnic',
      morning_slot: TimeSlot.find_by(name: 'Cherry Blossom Picnic', morning: true, event_id: event.id),
      start_time: '27 Mar 2050 13:00 JST +09:00',
      end_time: '27 Mar 2050 18:00 JST +09:00',
      description: 'Enjoy a nice picnic under the cherry blossoms!',
      registration_deadline: '25 Mar 2050'
    },
    {
      name: 'Cute Grass Head',
      morning_slot: TimeSlot.find_by(name: 'Cute Grass Head', morning: true, event_id: event.id),
      start_time: '28 Mar 2050 13:00 JST +09:00',
      end_time: '28 Mar 2050 18:00 JST +09:00',
      description: "Make your own little friend, in case you're ever stranded on a deserted island!",
      registration_deadline: '26 Mar 2050'
    },
    {
      name: 'Photo Frame',
      morning_slot: TimeSlot.find_by(name: 'Photo Frame', morning: true, event_id: event.id),
      start_time: '29 Mar 2050 13:00 JST +09:00',
      end_time: '29 Mar 2050 18:00 JST +09:00',
      description: 'Make a special photo frame to store your most precious memories!',
      registration_deadline: '27 Mar 2050'
    },
    {
      name: 'Marble Pencil Holder',
      morning_slot: TimeSlot.find_by(name: 'Marble Pencil Holder', morning: true, event_id: event.id),
      start_time: '30 Mar 2050 13:00 JST +09:00',
      end_time: '30 Mar 2050 18:00 JST +09:00',
      description: "Don't like holding pencils? Make something to do it for you!",
      registration_deadline: '28 Mar 2050'
    },
    {
      name: 'Spring Terrarium',
      morning_slot: TimeSlot.find_by(name: 'Spring Terrarium', morning: true, event_id: event.id),
      start_time: '31 Mar 2050 13:00 JST +09:00',
      end_time: '31 Mar 2050 18:00 JST +09:00',
      description: 'Create your own personal ecosystem to rule over!',
      registration_deadline: '29 Mar 2050'
    },
    {
      name: 'Ninja Master',
      morning_slot: TimeSlot.find_by(name: 'Ninja Master', morning: true, event_id: event.id),
      start_time: '3 Apr 2050 13:00 JST +09:00',
      end_time: '3 Apr 2050 18:00 JST +09:00',
      description: 'Become a ninja master!',
      registration_deadline: '1 Apr 2050'
    },
    {
      name: 'DIY Tic-Tac-Toe',
      morning_slot: TimeSlot.find_by(name: 'DIY Tic-Tac-Toe', morning: true, event_id: event.id),
      start_time: '4 Apr 2050 13:00 JST +09:00',
      end_time: '4 Apr 2050 18:00 JST +09:00',
      description: 'Make a game, then play it!',
      registration_deadline: '2 Apr 2050'
    },
    {
      name: 'Colorful Sand Art',
      morning_slot: TimeSlot.find_by(name: 'Colorful Sand Art', morning: true, event_id: event.id),
      start_time: '5 Apr 2050 13:00 JST +09:00',
      end_time: '5 Apr 2050 18:00 JST +09:00',
      description: 'Create art with a wave of nostalgia!',
      registration_deadline: '3 Apr 2050'
    },
    {
      name: 'Design a Kite & Castle Rush',
      morning_slot: TimeSlot.find_by(name: 'Banana Party & Banana Split', morning: true, event_id: event.id),
      start_time: '25 Mar 2050 14:00 JST +09:00',
      end_time: '25 Mar 2050 18:00 JST +09:00',
      description: 'Down with the bourgeoisie!',
      registration_deadline: '22 Mar 2050',
      category: 'special'
    }
  ])
end


puts 'Create afternoon time slots for spring school'


Event.all.each do |event|
  event.options.create!(
    name: 'Photo Service',
    description: "Capture your children's treasured memories!",
    category: :event,
    cost: 3000
  )
end

puts 'Added the photo service option to each event'



Event.where(name: 'Spring School 2023').each do |event|
  event.time_slots.each do |slot|
    slot.options.create!([
      {
        name: 'Arrive on time',
        category: :arrival,
        modifier: 0,
        description: 'Be normal!',
        cost: 0
      },
      {
        name: 'Arrive 30min early',
        category: :arrival,
        modifier: -30,
        description: 'Be at KU longer, for even more fun!',
        cost: 100
      },
      {
        name: 'Arrive 1hr early',
        category: :arrival,
        modifier: -60,
        description: 'Be at KU longer, for even more fun!',
        cost: 100
      },
      {
        name: 'Leave on time',
        category: :departure,
        modifier: 0,
        description: 'Be normal!',
        cost: 0
      },
      {
        name: 'Leave 30min late',
        category: :departure,
        modifier: +30,
        description: 'Be at KU longer, for even more fun!',
        cost: 100
      },
      {
        name: 'Leave 1hr late',
        category: :departure,
        modifier: +60,
        description: 'Be at KU longer, for even more fun!',
        cost: 100
      },
    ])
    slot.image.attach(io: File.open("app/assets/images/#{slot.name.downcase.gsub(' ', '_').gsub('_pm', '')}.jpg"), filename: 'logo.jpg', content_type: 'image/jpg')
  end
  event.time_slots.morning.each do |m_slot|
    m_slot.options.create!(
    name: '昼',
    description: 'Top up on energy through the day!',
    category: :meal,
    cost: 100
    )
  end
  event.time_slots.afternoon.each do |a_slot|
    a_slot.options.create!(
    name: '晩',
    description: 'Top up on energy through the day!',
    category: :meal,
    cost: 100
    )
  end
  event.time_slots.morning.where(category: :special).each do |sp_slot|
    sp_slot.options.create!(
      name: '中延長',
      description: 'Spend the whole day with friends!',
      category: :extension,
      cost: 100
      )
  end
end

puts 'Created options for spring school, and added images to slots'

School.all.each do |school|
  Child.all.each do |child|
    school.events.each do |event|
      child.invoices.create!([
        {
          event: event,
          total_cost: 0,
          billing_date: 1.year.from_now
        },
        {
          event: event,
          total_cost: 0,
          billing_date: 6.months.from_now,
          in_ss: true
        }
      ])
    end
  end
end

puts 'Created invoices for each child/event combo at each school'

School.all.each do |school|
  school.time_slots.each do |slot|
    school.children.each do |child|
      if slot.id.even?
        child.registrations.create!(registerable: slot, invoice: Invoice.find_by(child: child, event: slot.event))
      else
        child.registrations.create!(registerable: slot, invoice: Invoice.find_by(child: child, event: slot.event, in_ss: true))
      end
    end
  end
end

puts 'Registered children for each time slot at each event at their school'

Child.all.each do |child|
  child.time_slots.each do |slot|
    if child.id.odd?
      child.registrations.create!(registerable: slot.options.arrival.last, invoice: Invoice.find_by(child: child, event: slot.event)) unless slot.options.arrival.empty?
      child.registrations.create!(registerable: slot.options.departure.last, invoice: Invoice.find_by(child: child, event: slot.event)) unless slot.options.departure.empty?
    else
      child.registrations.create!(registerable: slot.options.regular.last, invoice: Invoice.find_by(child: child, event: slot.event)) unless slot.options.regular.empty?
      child.registrations.create!(registerable: slot.options.meal.last, invoice: Invoice.find_by(child: child, event: slot.event)) unless slot.options.meal.empty?
    end
  end

  child.events.each do |event|
    child.registrations.create!(registerable: event.options.first, invoice: Invoice.find_by(child: child, event: event))
  end
end

puts "Registered kids for first option for each event/slot they're attending"


Invoice.all.each do |invoice|
  invoice.calc_cost
end

puts 'Calculated invoice costs and added to SS now all are created'

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

non_member = User.create!(
    email: 'non_member@gmail.com',
    password: 'nonmembernon',
    ja_first_name: Faker::Name.first_name,
    ja_family_name: Faker::Name.last_name,
    katakana_name: Faker::Name.name.kana,
    role: :customer,
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number,
    school: School.all.find_by(name: '溝の口')
)

non_member.children.create!([
  {
    ja_first_name: Faker::Name.first_name,
    ja_family_name: Faker::Name.last_name,
    katakana_name: Faker::Name.name.kana,
    en_name: %w[Timmy Sally Billy Sarah Viktoria Brett].sample,
    birthday: Faker::Date.birthday(min_age: 2, max_age: 13),
    ssid: Faker::Number.unique.number,
    ele_school_name: Faker::GreekPhilosophers.name,
    post_photos: true,
    allergies: true,
    allergy_details: 'peanuts',
    kindy: true,
    category: :external,
    school: non_member.school
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
    allergies: true,
    allergy_details: 'peanuts',
    kindy: false,
    category: :external,
    school: non_member.school
  }
])

member = User.create!(
  email: 'member@gmail.com',
  password: 'membermembermember',
  ja_first_name: Faker::Name.first_name,
  ja_family_name: Faker::Name.last_name,
  katakana_name: Faker::Name.name.kana,
  role: :customer,
  address: Faker::Address.full_address,
  phone: Faker::PhoneNumber.phone_number,
  school: School.all.find_by(name: '溝の口')
)

member.children.create!([
{
  ja_first_name: Faker::Name.first_name,
  ja_family_name: Faker::Name.last_name,
  katakana_name: Faker::Name.name.kana,
  en_name: %w[Timmy Sally Billy Sarah Viktoria Brett].sample,
  birthday: Faker::Date.birthday(min_age: 2, max_age: 13),
  ssid: Faker::Number.unique.number,
  ele_school_name: Faker::GreekPhilosophers.name,
  post_photos: true,
  needs_hat: false,
  allergies: true,
  allergy_details: 'peanuts',
  kindy: true,
  category: 'internal',
  school: member.school
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
  needs_hat: false,
  allergies: true,
  allergy_details: 'peanuts',
  kindy: false,
  category: 'internal',
  school: member.school
}
])

member.children.each do |child|
  child.create_regular_schedule!(
    monday: true,
    tuesday: false,
    wednesday: true,
    thursday: false,
    friday: false
  )
end

puts 'Created test users for only member children and only non-member children, with no registrations'


# TODO: add back in once coupons are properly implemented
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