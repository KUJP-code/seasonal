School.all.each do |school|
  school.events.create!(
    name: 'Spring School 2023',
    description: 'See the sakura and celebrate spring with KU!',
    start_date: 'March 16 2050',
    end_date: 'April 4 2050',
    member_prices_id: 1,
    non_member_prices_id: 2,
    goal: 1_000_000
  )
end

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
end

# Create afternoon slots for all the morning slots
Event.all.each do |event|
  event.time_slots.morning.each do |slot|
    name = if slot.special?
             'Design a Kite & Castle Rush'
           else
             slot.name
           end

    slot.create_afternoon_slot(
      name: name,
      morning: false,
      category: slot.category,
      start_time: slot.start_time + 5.hours,
      end_time: slot.end_time + 5.hours,
      event_id: slot.event_id
    )
  end
end

# Add an image for the first event, and attach it to all of them

bucket_name = ENV['S3_BUCKET_NAME']
client = Aws::S3::Client.new(region: 'ap-northeast-1')
event_asset_key = "images/events/spring_school_2023.jpg"
event_key = "staging/events/spring_school_2023.jpg"
event_image = client.get_object(bucket: bucket_name, key: asset_key)

Event.first.image.attach(key: event_key, io: event_image.body, filename: "spring_school_2023.jpg", content_type: 'image/jpg')

blob = ActiveStorage::Blob.find_by(key: event_key)

Event.all.excluding(Event.first).each do |event|
  event.image.attach(blob)
end

# Add an image for each different (morning) slot, and attach it to all of them

slot_names = TimeSlot.group(:name).count.keys

slot_names.each do |name|
  next if name == 'Design a Kite & Castle Rush'
  filename = "#{name.downcase.gsub(' ', '_')}.jpg"
  slot_asset_key = "images/time_slots/spring_school_2023/#{filename}"
  slot_key = "staging/time_slots/#{filename}"
  slot_image = client.get_object(bucket: bucket_name, key: slot_asset_key)

  first_slot = TimeSlot.find_by(name: name)
  first_slot.image.attach(key: slot_key, io: slot_image.body, filename: filename, content_type: 'image/jpg')

  blob = ActiveStorage::Blob.find_by(key: slot_key)

  TimeSlot.where(name: name).excluding(first_slot).each do |slot|
    slot.image.attach(blob)
  end
end