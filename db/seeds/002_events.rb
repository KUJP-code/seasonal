PriceList.create!(
  [{ name: 'Spring 2024 Member', course1: '5_000', course3: '11_900', course5: '19_600',
     course10: '34_600', course15: '51_900', course20: '69_200', course25: '86_500',
     course30: '103_800', course35: '121_000', course40: '138_000', course45: '155_000',
     course50: '170_000' },
   { name: 'Spring 2024 Non-Member', course1: '6_930', course3: '19_100', course5: '31_500',
     course10: '57_750', course15: '84_000', course20: '105_000', course25: '126_000',
     course30: '147_000', course35: '168_000', course40: '189_000', course45: '209_000',
     course50: '229_000' }]
)

# Upload TimeSlot images

colorful_tape = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/colorful_tape.avif')),
  filename: 'colorful_tape.avif'
)

picture_keychain = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/picture_keychain.avif')),
  filename: 'picture_keychain.avif'
)

explorer_quest = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/explorer_quest.avif')),
  filename: 'explorer_quest.avif'
)

water_balloon_baseball_725 = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/water_balloon_baseball_725.avif')),
  filename: 'water_balloon_baseball_725.avif'
)

ninja_day = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/ninja_day.avif')),
  filename: 'ninja_day.avif'
)

fruit_smoothie = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/fruit_smoothie.avif')),
  filename: 'fruit_smoothie.avif'
)

games_of_the_world = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/games_of_the_world.avif')),
  filename: 'games_of_the_world.avif'
)

special_day = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/special_day.avif')),
  filename: 'special_day.avif'
)

cactus_craft = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/cactus_craft.avif')),
  filename: 'cactus_craft.avif'
)

hawaiian_shaved_ice = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/hawaiian_shaved_ice.avif')),
  filename: 'hawaiian_shaved_ice.avif'
)

water_gun_82 = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/water_gun_82.avif')),
  filename: 'water_gun_82.avif'
)

ocean_slime = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/ocean_slime.avif')),
  filename: 'ocean_slime.avif'
)

game_center = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/game_center.avif')),
  filename: 'game_center.avif'
)

water_gun_88 = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/water_gun_88.avif')),
  filename: 'water_gun_88.avif'
)

design_a_bag = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/design_a_bag.avif')),
  filename: 'design_a_bag.avif'
)

dessert_slime = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/dessert_slime.avif')),
  filename: 'dessert_slime.avif'
)

water_games = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/water_games.avif')),
  filename: 'water_games.avif'
)

water_gun_821 = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/water_gun_821.avif')),
  filename: 'water_gun_821.avif'
)

bandana_tie_dye = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/bandana_tie_dye.avif')),

  filename: 'bandana_tie_dye.avif'
)

glow_slime = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/glow_slime.avif')),
  filename: 'glow_slime.avif'
)

diy_aquarium = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/diy_aquarium.avif')),
  filename: 'diy_aquarium.avif'
)

shell_pendant = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/shell_pendant.avif')),
  filename: 'shell_pendant.avif'
)

water_balloon_baseball_828 = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/water_balloon_baseball_828.avif')),
  filename: 'water_balloon_baseball_828.avif'
)

rainbow_bag_charm = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/rainbow_bag_charm.avif')),
  filename: 'rainbow_bag_charm.avif'
)

beach_diorama = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/beach_diorama.avif')),
  filename: 'beach_diorama.avif'
)

bbq_yakisoba = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/bbq_yakisoba.avif')),
  filename: 'bbq_yakisoba.avif'
)

hot_dogs = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/hot_dogs.avif')),
  filename: 'hot_dogs.avif'
)

french_crepe = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/french_crepe.avif')),
  filename: 'french_crepe.avif'
)

# Create TimeSlot attributes

time_slot_attrs = [
  { name: 'Colorful Tape Art',
    avif: colorful_tape,
    morning: true,
    start_time: 1.day.from_now,
    end_time: 1.day.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'Picture Keychain',
    avif: picture_keychain,
    morning: true,
    start_time: 2.days.from_now,
    end_time: 2.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'Explorer Quest',
    avif: explorer_quest,
    morning: true,
    start_time: 3.days.from_now,
    end_time: 3.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'Water Balloon Baseball (7/25)',
    avif: water_balloon_baseball_725,
    morning: true,
    category: :outdoor,
    start_time: 4.days.from_now,
    end_time: 4.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'Ninja Day!',
    avif: ninja_day,
    morning: true,
    start_time: 5.days.from_now,
    end_time: 5.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'Fruit Smoothie',
    avif: fruit_smoothie,
    morning: true,
    start_time: 6.days.from_now,
    end_time: 6.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'Games of the World',
    avif: games_of_the_world,
    morning: true,
    start_time: 7.days.from_now,
    end_time: 7.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'Water Gun Fight & Watermelon Smash',
    avif: special_day,
    morning: true,
    start_time: 8.days.from_now,
    category: :special,
    end_time: 8.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'Cactus Craft',
    avif: cactus_craft,
    morning: true,
    start_time: 9.days.from_now,
    end_time: 9.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'Hawaiian Shaved Ice',
    avif: hawaiian_shaved_ice,
    morning: true,
    start_time: 10.days.from_now,
    end_time: 10.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'Water Gun (8/2)',
    avif: water_gun_82,
    morning: true,
    category: :outdoor,
    start_time: 11.days.from_now,
    end_time: 11.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'Ocean Slime',
    avif: ocean_slime,
    morning: true,
    start_time: 12.days.from_now,
    end_time: 12.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'Game Center',
    avif: game_center,
    morning: true,
    start_time: 13.days.from_now,
    end_time: 13.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'Water Gun (8/8)',
    avif: water_gun_88,
    morning: true,
    category: :outdoor,
    start_time: 14.days.from_now,
    end_time: 14.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'Design a Bag',
    avif: design_a_bag,
    morning: true,
    start_time: 15.days.from_now,
    end_time: 15.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'Dessert Slime',
    avif: dessert_slime,
    morning: true,
    start_time: 16.days.from_now,
    end_time: 16.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'Water Games',
    avif: water_games,
    morning: true,
    category: :outdoor,
    start_time: 17.days.from_now,
    end_time: 17.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'Water Gun (8/21)',
    avif: water_gun_821,
    morning: true,
    category: :outdoor,
    start_time: 18.days.from_now,
    end_time: 18.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'Bandana Tie-Dye',
    avif: bandana_tie_dye,
    morning: true,
    start_time: 19.days.from_now,
    end_time: 19.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'Glow Slime',
    avif: glow_slime,
    morning: true,
    start_time: 20.days.from_now,
    end_time: 20.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'DIY Aquarium',
    avif: diy_aquarium,
    morning: true,
    start_time: 21.days.from_now,
    end_time: 21.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'Shell Pendant',
    avif: shell_pendant,
    morning: true,
    start_time: 22.days.from_now,
    end_time: 22.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'Water Balloon Baseball (8/28)',
    avif: water_balloon_baseball_828,
    morning: true,
    category: :outdoor,
    start_time: 23.days.from_now,
    end_time: 23.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'Rainbow Bag Charm',
    avif: rainbow_bag_charm,
    morning: true,
    start_time: 24.days.from_now,
    end_time: 24.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'Beach Diorama',
    avif: beach_diorama,
    morning: true,
    start_time: 25.days.from_now,
    end_time: 25.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'BBQ Yakisoba!',
    avif: bbq_yakisoba,
    morning: true,
    start_time: 26.days.from_now,
    end_time: 26.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'Hot Dogs',
    avif: hot_dogs,
    morning: true,
    start_time: 27.days.from_now,
    end_time: 27.days.from_now + 3.hours,
    close_at: 1.month.from_now },
  { name: 'French Crepe',
    avif: french_crepe,
    morning: true,
    start_time: 28.days.from_now,
    end_time: 28.days.from_now + 3.hours,
    close_at: 1.month.from_now }
]

event_image = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app/assets/images/summer_2023.avif')),
  filename: 'summer_2023.avif'
)

puts 'Uploaded TimeSlot & Event images...'

School.where.not(name: 'Test').each do |school|
  event = school.events.create!(
    name: 'Summer School', start_date: 1.month.from_now, end_date: 2.months.from_now,
    member_prices_id: 1, non_member_prices_id: 2, goal: 2_000_000, avif: event_image
  )
  Option.create!(name: 'Photo Service', category: :event,
                 optionable: event, cost: 1_100)

  created_slots =
    TimeSlot.create!(time_slot_attrs.map { |attrs| attrs.merge(event_id: event.id) })

  # Add an afternoon slot for the special day so it supports full-day + 中延長 testing.
  special_morning =
    created_slots.find { |slot| slot.morning? && slot.special? && slot.afternoon_slot.nil? }
  if special_morning
    special_morning.create_afternoon_slot!(
      name: special_morning.name,
      start_time: special_morning.start_time + 5.hours,
      end_time: special_morning.end_time + 5.hours,
      close_at: special_morning.close_at,
      category: :special,
      morning: false,
      event_id: event.id,
      snack: true
    )
  end
end

puts 'Creating Party event'

party_prices = PriceList.create!(
  name: 'Party Price List', course1: '3500', course3: '10500', course5: '0',
  course10: '0', course15: '0', course20: '0', course25: '0',
  course30: '0', course35: '0', course40: '0', course45: '0',
  course50: '0'
)

School.where.not(name: 'Test').each do |school|
  event = school.events.create!(
    name: 'Test Party', start_date: 2.months.from_now, end_date: 2.months.from_now,
    member_prices_id: party_prices.id, non_member_prices_id: party_prices.id, goal: 10,
    early_bird_date: 1.month.from_now, early_bird_discount: -500
  )

  4.times do |i|
    event.time_slots.create!(name: "Party #{i}", start_time: 2.months.from_now, morning: true,
                             end_time: 2.months.from_now + 2.hours, close_at: 2.months.from_now)
  end
end
