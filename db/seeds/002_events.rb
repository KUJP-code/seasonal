PriceList.create!(
  [{ name: 'Spring 2024 Member', course1: 5_000, course3: 11_900, course5: 19_600,
     course10: 34_600, course15: 51_900, course20: 69_200, course25: 86_500,
     course30: 103_800, course35: 121_000, course40: 138_000, course45: 155_000,
     course50: 170_000 },
   { name: 'Spring 2024 Non-Member', course1: 6_930, course3: 19_100, course5: 31_500,
     course10: 57_750, course15: 84_000, course20: 105_000, course25: 126_000,
     course30: 147_000, course35: 168_000, course40: 189_000, course45: 209_000,
     course50: 229_000 }]
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
    start_time: '20 July 2023 10:00 JST +09:00',
    end_time: '20 July 2023 13:30 JST +09:00' },
  { name: 'Picture Keychain',
    avif: picture_keychain,
    morning: true,
    start_time: '21 July 2023 10:00 JST +09:00',
    end_time: '21 July 2023 13:30 JST +09:00' },
  { name: 'Explorer Quest',
    avif: explorer_quest,
    morning: true,
    start_time: '24 July 2023 10:00 JST +09:00',
    end_time: '24 July 2023 13:30 JST +09:00' },
  { name: 'Water Balloon Baseball (7/25)',
    avif: water_balloon_baseball_725,
    morning: true,
    category: :outdoor,
    start_time: '25 July 2023 10:00 JST +09:00',
    end_time: '25 July 2023 13:30 JST +09:00' },
  { name: 'Ninja Day!',
    avif: ninja_day,
    morning: true,
    start_time: '26 July 2023 10:00 JST +09:00',
    end_time: '26 July 2023 13:30 JST +09:00' },
  { name: 'Fruit Smoothie',
    avif: fruit_smoothie,
    morning: true,
    start_time: '27 July 2023 10:00 JST +09:00',
    end_time: '27 July 2023 13:30 JST +09:00' },
  { name: 'Games of the World',
    avif: games_of_the_world,
    morning: true,
    start_time: '28 July 2023 10:00 JST +09:00',
    end_time: '28 July 2023 13:30 JST +09:00' },
  { name: 'Water Gun Fight & Watermelon Smash',
    avif: special_day,
    morning: true,
    start_time: '29 July 2023 10:00 JST +09:00',
    category: :special,
    end_time: '29 July 2023 13:30 JST +09:00' },
  { name: 'Cactus Craft',
    avif: cactus_craft,
    morning: true,
    start_time: '31 July 2023 10:00 JST +09:00',
    end_time: '31 July 2023 13:30 JST +09:00' },
  { name: 'Hawaiian Shaved Ice',
    avif: hawaiian_shaved_ice,
    morning: true,
    start_time: '1 August 2023 10:00 JST +09:00',
    end_time: '1 August 2023 13:30 JST +09:00' },
  { name: 'Water Gun (8/2)',
    avif: water_gun_82,
    morning: true,
    category: :outdoor,
    start_time: '2 August 2023 10:00 JST +09:00',
    end_time: '2 August 2023 13:30 JST +09:00' },
  { name: 'Ocean Slime',
    avif: ocean_slime,
    morning: true,
    start_time: '4 August 2023 10:00 JST +09:00',
    end_time: '4 August 2023 13:30 JST +09:00' },
  { name: 'Game Center',
    avif: game_center,
    morning: true,
    start_time: '7 August 2023 10:00 JST +09:00',
    end_time: '7 August 2023 13:30 JST +09:00' },
  { name: 'Water Gun (8/8)',
    avif: water_gun_88,
    morning: true,
    category: :outdoor,
    start_time: '8 August 2023 10:00 JST +09:00',
    end_time: '8 August 2023 13:30 JST +09:00' },
  { name: 'Design a Bag',
    avif: design_a_bag,
    morning: true,
    start_time: '16 August 2023 10:00 JST +09:00',
    end_time: '16 August 2023 13:30 JST +09:00' },
  { name: 'Dessert Slime',
    avif: dessert_slime,
    morning: true,
    start_time: '17 August 2023 10:00 JST +09:00',
    end_time: '17 August 2023 13:30 JST +09:00' },
  { name: 'Water Games',
    avif: water_games,
    morning: true,
    category: :outdoor,
    start_time: '18 August 2023 10:00 JST +09:00',
    end_time: '18 August 2023 13:30 JST +09:00' },
  { name: 'Water Gun (8/21)',
    avif: water_gun_821,
    morning: true,
    category: :outdoor,
    start_time: '21 August 2023 10:00 JST +09:00',
    end_time: '21 August 2023 13:30 JST +09:00' },
  { name: 'Bandana Tie-Dye',
    avif: bandana_tie_dye,
    morning: true,
    start_time: '22 August 2023 10:00 JST +09:00',
    end_time: '22 August 2023 13:30 JST +09:00' },
  { name: 'Glow Slime',
    avif: glow_slime,
    morning: true,
    start_time: '23 August 2023 10:00 JST +09:00',
    end_time: '23 August 2023 13:30 JST +09:00' },
  { name: 'DIY Aquarium',
    avif: diy_aquarium,
    morning: true,
    start_time: '24 August 2023 10:00 JST +09:00',
    end_time: '24 August 2023 13:30 JST +09:00' },
  { name: 'Shell Pendant',
    avif: shell_pendant,
    morning: true,
    start_time: '25 August 2023 10:00 JST +09:00',
    end_time: '25 August 2023 13:30 JST +09:00' },
  { name: 'Water Balloon Baseball (8/28)',
    avif: water_balloon_baseball_828,
    morning: true,
    category: :outdoor,
    start_time: '28 August 2023 10:00 JST +09:00',
    end_time: '28 August 2023 13:30 JST +09:00' },
  { name: 'Rainbow Bag Charm',
    avif: rainbow_bag_charm,
    morning: true,
    start_time: '29 August 2023 10:00 JST +09:00',
    end_time: '29 August 2023 13:30 JST +09:00' },
  { name: 'Beach Diorama',
    avif: beach_diorama,
    morning: true,
    start_time: '30 August 2023 10:00 JST +09:00',
    end_time: '30 August 2023 13:30 JST +09:00' },
  { name: 'BBQ Yakisoba!',
    avif: bbq_yakisoba,
    morning: true,
    start_time: '3 August 2023 10:00 JST +09:00',
    end_time: '3 August 2023 13:30 JST +09:00' },
  { name: 'Hot Dogs',
    avif: hot_dogs,
    morning: true,
    start_time: '9 August 2023 10:00 JST +09:00',
    end_time: '9 August 2023 13:30 JST +09:00' },
  { name: 'French Crepe',
    avif: french_crepe,
    morning: true,
    start_time: '31 August 2023 10:00 JST +09:00',
    end_time: '31 August 2023 13:30 JST +09:00' }
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

  TimeSlot.create!(time_slot_attrs.map { |attrs| attrs.merge(event_id: event.id) })
end
