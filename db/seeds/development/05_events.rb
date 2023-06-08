School.all.each do |school|
  school.events.create!(
    name: 'Summer School',
    start_date: 'July 20 2023',
    end_date: 'August 31 2023',
    member_prices_id: 1,
    non_member_prices_id: 2,
    goal: 3_000_000
  )
end

puts 'Created Summer school at each school'

Event.all.each do |event|
  event.time_slots.create!([
    {
      name: 'Colorful Tape Art',
      morning: true,
      start_time: '20 July 2023 10:00 JST +09:00',
      end_time: '20 July 2023 13:30 JST +09:00'
    },
    {
      name: 'Picture Keychain',
      morning: true,
      start_time: '21 July 2023 10:00 JST +09:00',
      end_time: '21 July 2023 13:30 JST +09:00'
    },
    {
      name: "Explorer Quest",
      morning: true,
      start_time: '24 July 2023 10:00 JST +09:00',
      end_time: '24 July 2023 13:30 JST +09:00'
    },
    {
      name: 'Water Balloon Baseball (7/25)',
      morning: true,
      category: :outdoor,
      start_time: '25 July 2023 10:00 JST +09:00',
      end_time: '25 July 2023 13:30 JST +09:00'
    },
    {
      name: 'Ninja Day!',
      morning: true,
      start_time: '26 July 2023 10:00 JST +09:00',
      end_time: '26 July 2023 13:30 JST +09:00'
    },
    {
      name: 'Fruit Smoothie',
      morning: true,
      start_time: '27 July 2023 10:00 JST +09:00',
      end_time: '27 July 2023 13:30 JST +09:00'
    },
    {
      name: 'Games of the World',
      morning: true,
      start_time: '28 July 2023 10:00 JST +09:00',
      end_time: '28 July 2023 13:30 JST +09:00'
    },
    {
      name: 'Water Gun Fight & Watermelon Smash',
      morning: true,
      start_time: '29 July 2023 10:00 JST +09:00',
      end_time: '29 July 2023 13:30 JST +09:00',
      category: :special
    },
    {
      name: 'Cactus Craft',
      morning: true,
      start_time: '31 July 2023 10:00 JST +09:00',
      end_time: '31 July 2023 13:30 JST +09:00'
    },
    {
      name: 'Hawaiian Shaved Ice',
      morning: true,
      start_time: '1 August 2023 10:00 JST +09:00',
      end_time: '1 August 2023 13:30 JST +09:00'
    },
    {
      name: 'Water Gun (8/2)',
      morning: true,
      category: :outdoor,
      start_time: '2 August 2023 10:00 JST +09:00',
      end_time: '2 August 2023 13:30 JST +09:00'
    },
    {
      name: "Ocean Slime",
      morning: true,
      start_time: '4 August 2023 10:00 JST +09:00',
      end_time: '4 August 2023 13:30 JST +09:00'
    },
    {
      name: 'Game Center',
      morning: true,
      start_time: '7 August 2023 10:00 JST +09:00',
      end_time: '7 August 2023 13:30 JST +09:00'
    },
    {
      name: 'Water Gun (8/8)',
      morning: true,
      category: :outdoor,
      start_time: '8 August 2023 10:00 JST +09:00',
      end_time: '8 August 2023 13:30 JST +09:00'
    },
    {
      name: 'Design a Bag',
      morning: true,
      start_time: '16 August 2023 10:00 JST +09:00',
      end_time: '16 August 2023 13:30 JST +09:00'
    },
    {
      name: 'Dessert Slime',
      morning: true,
      start_time: '17 August 2023 10:00 JST +09:00',
      end_time: '17 August 2023 13:30 JST +09:00'
    },
    {
      name: 'Water Games',
      morning: true,
      category: :outdoor,
      start_time: '18 August 2023 10:00 JST +09:00',
      end_time: '18 August 2023 13:30 JST +09:00'
    },
    {
      name: 'Water Gun (8/21)',
      morning: true,
      category: :outdoor,
      start_time: '21 August 2023 10:00 JST +09:00',
      end_time: '21 August 2023 13:30 JST +09:00'
    },
    {
      name: 'Bandana Tie-Dye',
      morning: true,
      start_time: '22 August 2023 10:00 JST +09:00',
      end_time: '22 August 2023 13:30 JST +09:00'
    },
    {
      name: 'Glow Slime',
      morning: true,
      start_time: '23 August 2023 10:00 JST +09:00',
      end_time: '23 August 2023 13:30 JST +09:00'
    },
    {
      name: 'DIY Aquarium',
      morning: true,
      start_time: '24 August 2023 10:00 JST +09:00',
      end_time: '24 August 2023 13:30 JST +09:00'
    },
    {
      name: 'Shell Pendant',
      morning: true,
      start_time: '25 August 2023 10:00 JST +09:00',
      end_time: '25 August 2023 13:30 JST +09:00'
    },
    {
      name: 'Water Balloon Baseball (8/28)',
      morning: true,
      category: :outdoor,
      start_time: '28 August 2023 10:00 JST +09:00',
      end_time: '28 August 2023 13:30 JST +09:00'
    },
    {
      name: 'Rainbow Bag Charm',
      morning: true,
      start_time: '29 August 2023 10:00 JST +09:00',
      end_time: '29 August 2023 13:30 JST +09:00'
    },
    {
      name: 'Beach Diorama',
      morning: true,
      start_time: '30 August 2023 10:00 JST +09:00',
      end_time: '30 August 2023 13:30 JST +09:00'
    }
  ])
end

puts 'Created morning time slots for Summer school'

# Create the different slots for normal schools
different_schools = %w[新浦安 南町田グランベリーパーク]

# Create the different slots for Minami-machida and Shin-Urayasu
School.all.where(name: different_schools).each do |school|
  school.events.first.time_slots.create!([
    {
      name: 'Paper Lantern',
      morning: true,
      start_time: '3 August 2023 10:00 JST +09:00',
      end_time: '3 August 2023 13:30 JST +09:00'
    },
    {
      name: 'Oreo Milkshake',
      morning: true,
      start_time: '9 August 2023 10:00 JST +09:00',
      end_time: '9 August 2023 13:30 JST +09:00'
    },
    {
      name: 'Icecream Store',
      morning: true,
      start_time: '31 August 2023 10:00 JST +09:00',
      end_time: '31 August 2023 13:30 JST +09:00'
    }
  ])
end

# Create the normal slots
School.all.where.not(name: different_schools).each do |school|
  school.events.first.time_slots.create!([
    {
      name: 'BBQ Yakisoba!',
      morning: true,
      start_time: '3 August 2023 10:00 JST +09:00',
      end_time: '3 August 2023 13:30 JST +09:00'
    },
    {
      name: 'Hot Dogs',
      morning: true,
      start_time: '9 August 2023 10:00 JST +09:00',
      end_time: '9 August 2023 13:30 JST +09:00'
    },
    {
      name: 'French Crepe',
      morning: true,
      start_time: '31 August 2023 10:00 JST +09:00',
      end_time: '31 August 2023 13:30 JST +09:00'
    }
  ])
end

# Create all afternoon slots
Event.all.each do |event|
  event.time_slots.morning.each do |slot|
    # Make sure the afternoon of the special day gets its own name
    name = slot.special? ? 'Giant Castle & Icecream Store' : slot.name
    slot.create_afternoon_slot(
      name: name,
      start_time: slot.start_time + 5.hours,
      end_time: slot.end_time + 5.hours,
      category: slot.category,
      morning: false,
      event_id: slot.event_id
    )
  end
end

# Add event images for no food events
event_key = "#{Rails.env}/events/summer_2023.png"

Event.all.select { |e| different_schools.include?(e.school.name) }.first.image.attach(key: event_key, io: File.open("app/assets/images/summer_2023.png"), filename: "summer_2023.png", content_type: 'image/png')

blob = ActiveStorage::Blob.find_by(key: event_key)

Event.all.excluding(Event.first).each do |event|
  event.image.attach(blob)
end


# Add event images for regular events
event_key = "#{Rails.env}/events/summer_2023_food.png"

Event.all.reject { |e| different_schools.include?(e.school.name) }.first.image.attach(key: event_key, io: File.open("app/assets/images/summer_2023_food.png"), filename: "summer_2023_food.png", content_type: 'image/png')

blob = ActiveStorage::Blob.find_by(key: event_key)

Event.all.excluding(Event.first).each do |event|
  event.image.attach(blob)
end

puts 'Added the event image to each Summer School'

slot_names = TimeSlot.group(:name).count.keys

slot_names.each do |name|
  next if name == 'Giant Castle & Icecream Store'

  filename = name == 'Water Gun Fight & Watermelon Smash' ? 'special_day.png' : "#{name.downcase.gsub(' ', '_').gsub(/[()\/]/, '')}.png"
  slot_key = "#{Rails.env}/slots/#{filename}.png"

  first_slot = TimeSlot.find_by(name: name, morning: true)
  first_slot.image.attach(key: slot_key, io: File.open("app/assets/images/#{filename}"), filename: filename, content_type: 'image/png')

  blob = ActiveStorage::Blob.find_by(key: slot_key)

  TimeSlot.where(name: name).excluding(first_slot).each do |slot|
    slot.image.attach(blob)
  end
end

puts 'Added images to each morning slot'