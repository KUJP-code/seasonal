choco_descrip = 'Make chocolate, play chocolate related games and learn English!'

School.all.each do |school|
    school.events.create!([
      {
        name: 'Chocolate Day 2024',
        description: choco_descrip,
        start_date: 'February 18 2051',
        end_date: 'February 18 2051',
        member_prices_id: 1,
        non_member_prices_id: 2,
        goal: 500_000
      },
      {
        name: 'Spring School 2023',
        description: 'See the sakura and celebrate spring with KU!',
        start_date: 'March 16 2050',
        end_date: 'April 4 2050',
        member_prices_id: 1,
        non_member_prices_id: 2,
        goal: 1_000_000
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
      category: :party
    },
    {
      name: 'Chocolate Day 11am',
      morning: true,
      start_time: '18 Feb 2051 11:00 JST +09:00',
      end_time: '18 Feb 2051 12:00 JST +09:00',
      description: choco_descrip,
      category: :party
    },
    {
      name: 'Chocolate Day 2pm',
      morning: true,
      start_time: '18 Feb 2051 14:00 JST +09:00',
      end_time: '18 Feb 2051 16:00 JST +09:00',
      description: choco_descrip,
      category: :party
    },
    {
      name: 'Chocolate Day 4pm',
      morning: true,
      start_time: '18 Feb 2051 16:00 JST +09:00',
      end_time: '18 Feb 2051 18:00 JST +09:00',
      description: choco_descrip,
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
    },
    {
      name: 'Butterfly Finger Puppet',
      morning: true,
      start_time: '17 Mar 2050 9:00 JST +09:00',
      end_time: '17 Mar 2050 13:00 JST +09:00',
      description: 'Make a cute butterfly puppet to take home and enjoy!',
    },
    {
      name: 'Magic Day',
      morning: true,
      start_time: '20 Mar 2050 9:00 JST +09:00',
      end_time: '20 Mar 2050 13:00 JST +09:00',
      description: 'Learn magic tricks that will dazzle your family!',
    },
    {
      name: 'Vegetable Stamps',
      morning: true,
      start_time: '22 Mar 2050 9:00 JST +09:00',
      end_time: '22 Mar 2050 13:00 JST +09:00',
      description: 'Create some beautiful (and healthy) artwork!',
    },
    {
      name: 'Spider Web Race',
      morning: true,
      start_time: '23 Mar 2050 9:00 JST +09:00',
      end_time: '23 Mar 2050 13:00 JST +09:00',
      description: 'Race out of a sticky situation!',
    },
    {
      name: 'Easter Egg Craft',
      morning: true,
      start_time: '24 Mar 2050 9:00 JST +09:00',
      end_time: '24 Mar 2050 13:00 JST +09:00',
      description: 'Create your own special Easter Egg! No eating though!',
    },
    {
      name: 'Banana Party & Banana Split',
      morning: true,
      start_time: '25 Mar 2050 9:00 JST +09:00',
      end_time: '25 Mar 2050 13:00 JST +09:00',
      description: 'Party like a banana then split!',
      category: 'special'
    },
    {
      name: 'Cherry Blossom Picnic',
      morning: true,
      start_time: '27 Mar 2050 9:00 JST +09:00',
      end_time: '27 Mar 2050 13:00 JST +09:00',
      description: 'Enjoy a nice picnic under the cherry blossoms!',
    },
    {
      name: 'Cute Grass Head',
      morning: true,
      start_time: '28 Mar 2050 9:00 JST +09:00',
      end_time: '28 Mar 2050 13:00 JST +09:00',
      description: "Make your own little friend, in case you're ever stranded on a deserted island!",
    },
    {
      name: 'Photo Frame',
      morning: true,
      start_time: '29 Mar 2050 9:00 JST +09:00',
      end_time: '29 Mar 2050 13:00 JST +09:00',
      description: 'Make a special photo frame to store your most precious memories!',
    },
    {
      name: 'Marble Pencil Holder',
      morning: true,
      start_time: '30 Mar 2050 9:00 JST +09:00',
      end_time: '30 Mar 2050 13:00 JST +09:00',
      description: "Don't like holding pencils? Make something to do it for you!",
    },
    {
      name: 'Spring Terrarium',
      morning: true,
      start_time: '31 Mar 2050 9:00 JST +09:00',
      end_time: '31 Mar 2050 13:00 JST +09:00',
      description: 'Create your own personal ecosystem to rule over!',
    },
    {
      name: 'Ninja Master',
      morning: true,
      start_time: '3 Apr 2050 9:00 JST +09:00',
      end_time: '3 Apr 2050 13:00 JST +09:00',
      description: 'Become a ninja master!',
    },
    {
      name: 'DIY Tic-Tac-Toe',
      morning: true,
      start_time: '4 Apr 2050 9:00 JST +09:00',
      end_time: '4 Apr 2050 13:00 JST +09:00',
      description: 'Make a game, then play it!',
    },
    {
      name: 'Colorful Sand Art',
      morning: true,
      start_time: '5 Apr 2050 9:00 JST +09:00',
      end_time: '5 Apr 2050 13:00 JST +09:00',
      description: 'Create art with a wave of nostalgia!',
    }
  ])
  event.image.attach(io: File.open('app/assets/images/spring_school_2023.jpg'), filename: 'logo.jpg', content_type: 'image/jpg')
end

puts 'Created time slots for spring school, and added images to the events'

TimeSlot.all.morning.each do |slot|
  slot.image.attach(io: File.open("app/assets/images/#{slot.name.downcase.gsub(' ', '_').gsub('_pm', '')}.jpg"), filename: 'logo.jpg', content_type: 'image/jpg')
end

puts 'Added images to each morning slot'