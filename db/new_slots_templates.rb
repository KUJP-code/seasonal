# Rinkai Triple
event = School.find_by(name: "りんかい東雲").events.first

event.time_slots.create!(
  name: "キッズアップハンター",
  morning: true,
  category: :special,
  start_time: '26 August 2023 9:30 JST +09:00',
  end_time: '26 August 2023 13:00 JST +09:00'
)

am = TimeSlot.find_by(name: "キッズアップハンター")
am.options.destroy_all
am.options.create!([
  {
    name: 'ティーチャーみずきとのピザパーティ',
    category: :extension,
    cost: 2000
  },
  {
    name: 'ティーチャーみずきとのピザパーティ',
    category: :k_extension,
    cost: 2000
  }
])

# Local
filename = "rinkai.jpg"
slot_key = "production/slots/#{filename}"
am.image.attach(key: slot_key, io: File.open("app/assets/images/#{filename}"), filename: filename, content_type: 'image/jpeg')

# Prod
bucket_name = ENV['S3_BUCKET_NAME']
client = Aws::S3::Client.new(region: 'ap-northeast-1')
filename = "rinkai.jpg"
slot_asset_key = "images/time_slots/summer_2023/#{filename}"
slot_key = "production/time_slots/#{filename}"
slot_image = client.get_object(bucket: bucket_name, key: slot_asset_key)
am.image.attach(key: slot_key, io: slot_image.body, filename: filename, content_type: 'image/jpeg')

am.create_afternoon_slot(
  name: "サマーモンスター",
  category: :special,
  morning: false,
  start_time: '26 August 2023 15:00 JST +09:00',
  end_time: '26 August 2023 18:30 JST +09:00',
  event_id: am.event_id
)

pm = am.afternoon_slot
pm.options.destroy_all

# Monzen
event = School.find_by(name: "門前仲町").events.first

# TODO: Get a list of the kids registered for the afternoons before doing this, then close them and re-register them for the new afternoon activities when done

# 18th

og_18th = event.time_slots.find_by(name: "ウォーターゲーム対決！")
og_18th.update!(category: :special)

# Local
filename = "monzen18.png"
slot_key = "production/slots/#{filename}"
og_18th.image.attach(key: slot_key, io: File.open("app/assets/images/#{filename}"), filename: filename, content_type: 'image/png')

# Prod
bucket_name = ENV['S3_BUCKET_NAME']
client = Aws::S3::Client.new(region: 'ap-northeast-1')
filename = "monzen18.png"
slot_asset_key = "images/time_slots/summer_2023/#{filename}"
slot_key = "production/time_slots/#{filename}"
slot_image = client.get_object(bucket: bucket_name, key: slot_asset_key)
og_18th.image.attach(key: slot_key, io: slot_image.body, filename: filename, content_type: 'image/png')

og_18th.afternoon_slot.destroy
og_18th.create_afternoon_slot(
  name: "フレンチクレープ",
  category: :special,
  morning: false,
  start_time: '18 August 2023 15:00 JST +09:00',
  end_time: '18 August 2023 18:30 JST +09:00',
  event_id: og_18th.event_id
)

pm = og_18th.afternoon_slot
pm.options.destroy_all

# 21st

og_21st = event.time_slots.find_by(name: "水鉄砲合戦!!(8月21日)")
og_21st.update!(category: :special)

# Local
filename = "monzen21.png"
slot_key = "production/slots/#{filename}"
og_21st.image.attach(key: slot_key, io: File.open("app/assets/images/#{filename}"), filename: filename, content_type: 'image/png')

# Prod
bucket_name = ENV['S3_BUCKET_NAME']
client = Aws::S3::Client.new(region: 'ap-northeast-1')
filename = "monzen21.png"
slot_asset_key = "images/time_slots/summer_2023/#{filename}"
slot_key = "production/time_slots/#{filename}"
slot_image = client.get_object(bucket: bucket_name, key: slot_asset_key)
og_21st.image.attach(key: slot_key, io: slot_image.body, filename: filename, content_type: 'image/png')

og_21st.afternoon_slot.destroy
og_21st.create_afternoon_slot(
  name: "ハワイアンかき氷 ",
  category: :special,
  morning: false,
  start_time: '21 August 2023 15:00 JST +09:00',
  end_time: '21 August 2023 18:30 JST +09:00',
  event_id: og_21st.event_id
)

pm = og_21st.afternoon_slot
pm.options.destroy_all

# TODO: Re-register aft kids now

# Monzen real special

event.time_slots.create!(
  name: "BBQ風やきそば/コーラの噴射実験",
  morning: true,
  category: :special,
  start_time: '2 September 2023 9:30 JST +09:00',
  end_time: '2 September 2023 13:00 JST +09:00'
)

am = TimeSlot.find_by(name: "BBQ風やきそば/コーラの噴射実験")
am.options.where(category: [:extension, :k_extension]).destroy_all

# Local
filename = "monzen_special.png"
slot_key = "production/slots/#{filename}"
am.image.attach(key: slot_key, io: File.open("app/assets/images/#{filename}"), filename: filename, content_type: 'image/png')

# Prod
bucket_name = ENV['S3_BUCKET_NAME']
client = Aws::S3::Client.new(region: 'ap-northeast-1')
filename = "monzen_special.png"
slot_asset_key = "images/time_slots/summer_2023/#{filename}"
slot_key = "production/time_slots/#{filename}"
slot_image = client.get_object(bucket: bucket_name, key: slot_asset_key)
am.image.attach(key: slot_key, io: slot_image.body, filename: filename, content_type: 'image/png')

am.create_afternoon_slot(
  name: "暗闇で光るスライム/フルーツスムージー",
  category: :special,
  morning: false,
  start_time: '2 September 2023 15:00 JST +09:00',
  end_time: '2 September 2023 18:30 JST +09:00',
  event_id: am.event_id
)

pm = am.afternoon_slot
pm.options.destroy_all

# Ikegami

event = School.find_by(name: "池上").events.first

event.time_slots.create!(
  name: "イングリッシュスポーツイベント",
  morning: true,
  category: :special,
  start_time: '2 September 2023 9:30 JST +09:00',
  end_time: '2 September 2023 13:00 JST +09:00'
)

am = TimeSlot.find_by(name: "イングリッシュスポーツイベント")
am.options.where(category: [:arrival, :k_arrival]).destroy_all

# Local
filename = "ikegami.png"
slot_key = "production/slots/#{filename}"
am.image.attach(key: slot_key, io: File.open("app/assets/images/#{filename}"), filename: filename, content_type: 'image/png')

# Prod
bucket_name = ENV['S3_BUCKET_NAME']
client = Aws::S3::Client.new(region: 'ap-northeast-1')
filename = "ikegami.png"
slot_asset_key = "images/time_slots/summer_2023/#{filename}"
slot_key = "production/time_slots/#{filename}"
slot_image = client.get_object(bucket: bucket_name, key: slot_asset_key)
am.image.attach(key: slot_key, io: slot_image.body, filename: filename, content_type: 'image/png')

am.create_afternoon_slot(
  name: "スペシャルクッキングイベント",
  category: :special,
  morning: false,
  start_time: '2 September 2023 15:00 JST +09:00',
  end_time: '2 September 2023 18:30 JST +09:00',
  event_id: am.event_id
)

pm = am.afternoon_slot
pm.options.destroy_all

# Magome

event = School.find_by(name: "馬込").events.first

event.time_slots.create!(
  name: "3校対決！Englishスポーツ大会",
  morning: true,
  category: :special,
  start_time: '2 September 2023 9:30 JST +09:00',
  end_time: '2 September 2023 13:00 JST +09:00'
)

am = TimeSlot.find_by(name: "3校対決！Englishスポーツ大会")
am.options.where(category: [:extension, :k_extension]).destroy_all

# Local
filename = "magome.png"
slot_key = "production/slots/#{filename}"
am.image.attach(key: slot_key, io: File.open("app/assets/images/#{filename}"), filename: filename, content_type: 'image/png')

# Prod
bucket_name = ENV['S3_BUCKET_NAME']
client = Aws::S3::Client.new(region: 'ap-northeast-1')
filename = "magome.png"
slot_asset_key = "images/time_slots/summer_2023/#{filename}"
slot_key = "production/time_slots/#{filename}"
slot_image = client.get_object(bucket: bucket_name, key: slot_asset_key)
am.image.attach(key: slot_key, io: slot_image.body, filename: filename, content_type: 'image/png')

# Nagahara

event = School.find_by(name: "長原").events.first

event.time_slots.create!(
  name: "スクール対抗スポーツ大会",
  morning: true,
  category: :special,
  start_time: '2 September 2023 9:30 JST +09:00',
  end_time: '2 September 2023 13:00 JST +09:00'
)

am = TimeSlot.find_by(name: "スクール対抗スポーツ大会")
am.options.where(category: [:extension, :k_extension]).destroy_all
am.options.create!([
  {
    name: '中延長',
    category: :extension,
    cost: 920
  },
  {
    name: '中延長',
    category: :k_extension,
    cost: 1_160
  }
])

# Local
filename = "nagahara.png"
slot_key = "production/slots/#{filename}"
am.image.attach(key: slot_key, io: File.open("app/assets/images/#{filename}"), filename: filename, content_type: 'image/png')

# Prod
bucket_name = ENV['S3_BUCKET_NAME']
client = Aws::S3::Client.new(region: 'ap-northeast-1')
filename = "nagahara.png"
slot_asset_key = "images/time_slots/summer_2023/#{filename}"
slot_key = "production/time_slots/#{filename}"
slot_image = client.get_object(bucket: bucket_name, key: slot_asset_key)
am.image.attach(key: slot_key, io: slot_image.body, filename: filename, content_type: 'image/png')

am.create_afternoon_slot(
  name: "遠足＠しながわ水族館",
  category: :special,
  morning: false,
  start_time: '2 September 2023 15:00 JST +09:00',
  end_time: '2 September 2023 18:30 JST +09:00',
  event_id: am.event_id
)

pm = am.afternoon_slot
pm.options.destroy_all