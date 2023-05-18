bucket_name = ENV['S3_BUCKET_NAME']
client = Aws::S3::Client.new(region: 'ap-northeast-1')

# Attach the calendar image to the first event
standard_asset_key = "images/events/summer_2023_food.png"
standard_key = "production/events/summer_2023_food.png"
standard_image = client.get_object(bucket: bucket_name, key: standard_asset_key)

Event.first.image.attach(key: standard_key, io: standard_image.body, filename: "summer_2023_food.png", content_type: 'image/png')
image_blob = ActiveStorage::Blob.find_by(key: standard_key)

# Attach standard calendar to events at schools other than shin-ura and minami machida
Event.all.excluding(Event.first).each do |event|
  event.image.attach(image_blob) unless different_schools.include?(event.school.name)
end

# Get the banner image
banner_asset_key = "images/events/summer_2023_banner.jpg"
banner_key = "production/events/summer_2023_banner.jpg"
banner_image = client.get_object(bucket: bucket_name, key: banner_asset_key)

Event.first.banner.attach(key: banner_key, io: banner_image.body, filename: "summer_2023_banner.jpg", content_type: 'image/jpg')
banner_blob = ActiveStorage::Blob.find_by(key: banner_key)

# Attach the banner to all events
Event.all.excluding(Event.first).each do |event|
  event.banner.attach(banner_blob)
end

# Get the different calendar images
diff_asset_key = "images/events/summer_2023.png"
diff_key = "production/events/summer_2023.png"
diff_image = client.get_object(bucket: bucket_name, key: diff_asset_key)

# Attach the different event images to minami and shin-ura
School.find_by(name: '新浦安').events.first.image.attach(key: diff_key, io: diff_image.body, filename: "summer_2023.png", content_type: 'image/png')
calendar_blob = ActiveStorage::Blob.find_by(key: diff_key)
School.find_by(name: '南町田グランベリーパーク').events.first.image.attach(calendar_blob)

# Add an image for each different (morning) slot, and attach it to all of them
slot_names = TimeSlot.group(:name).count.keys

# FIXME: About 11 of these still don't work, I give up. Will do it manually
filename_hash = {
  '冒険者のクエスト！' => 'explorer_quest',
  'オレオシェイク' => 'oreo_milkshake',
  '暗闇で光るスライム' => 'glow_slime',
  'デザートスライム' => 'dessert_slime',
  'オリジナルバッグ作り' => 'design_a_bag',
  '水鉄砲合戦!!(8月2日)' => 'water_gun_82',
  'フレンチクレープ' => 'french_crepe',
  'ウォーターベースボール(8月28日)' => 'water_balloon_baseball_828',
  '忍者になろう！' => 'ninja_day',
  'フルーシスムージー★' => 'fruit_smoothie',
  'ペーパーランタン' => 'paper_lantern',
  'サボテンクラフト' => 'cactus_craft',
  '貝殻ペンダント' => 'shell_pendant',
  'ウォーターゲーム対決！' => 'water_games',
  '水鉄砲合戦!!(8月21日)' => 'water_gun_821',
  'ウォーターベースボール(7月25日)' => 'water_balloon_baseball_725',
  'ビーチジオラマ' => 'beach_diorama',
  'レインボーキーホルダー' => 'rainbow_bag_charm',
  '水鉄砲合戦!!(8月8日)' => 'water_gun_88',
  '海のスライム' => 'ocean_slime',
  'ハワイアンかき氷' => 'hawaiian_shaved_ice',
  'DIY水族館' => 'diy_aquarium',
  '水鉄砲合＆スイカ割り！' => 'special_day',
  'カラフルテープアート' => 'colorful_tape_art',
  'Kids Up★ゲームセンター' => 'game_center',
  '焼きそばを作ろう' => 'yakisoba',
  'アイスクリーム屋さん' => 'icecream_store',
  'ピクチャーキーホルダー' => 'picture_keychain',
  'アメリカン★ホットドッグ' => 'hot_dogs',
  'バンダナの絞り染め' => 'bandana_tie_dye',
  '世界のゲームを体験しよう' => 'games_of_the_world'
}


slot_names.each do |name|
  filename = "#{translation_hash["#{name}"]}.png"
  slot_asset_key = "images/time_slots/summer_2023/#{filename}"
  slot_key = "production/time_slots/#{filename}"
  slot_image = client.get_object(bucket: bucket_name, key: slot_asset_key)

  first_slot = TimeSlot.find_by(name: name)
  first_slot.image.attach(key: slot_key, io: slot_image.body, filename: filename, content_type: 'image/png')

  slot_blob = ActiveStorage::Blob.find_by(key: slot_key)

  TimeSlot.where(name: name).excluding(first_slot).each do |slot|
    slot.image.attach(slot_blob)
  end
end