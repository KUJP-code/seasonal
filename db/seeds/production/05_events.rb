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
end

Event.where(name: 'Chocolate Day 2024').each do |event|
  event.time_slots.each do |slot|
    slot.options.create!(
        name: 'Commemorative Badge',
        description: 'Remember all the fun you had with this shiny badge!',
        cost: 100
      )
  end
end

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
end
