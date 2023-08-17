bucket_name = ENV['S3_BUCKET_NAME']
client = Aws::S3::Client.new(region: 'ap-northeast-1')

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

# 18th

og_18th = event.time_slots.find_by(name: "ウォーターゲーム対決！")
og_18th.update!(category: :special)

# Local
filename = "monzen18.png"
slot_key = "production/slots/#{filename}"
og_18th.image.attach(key: slot_key, io: File.open("app/assets/images/#{filename}"), filename: filename, content_type: 'image/png')

# Prod
filename = "monzen18.png"
slot_asset_key = "images/time_slots/summer_2023/#{filename}"
slot_key = "production/time_slots/#{filename}"
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

# Todoroki

event = School.find_by(name: "等々力").events.first

event.time_slots.create!(
  name: "具だくさんスライム＆光るタピオカパーティー☆彡",
  morning: true,
  category: :special,
  start_time: '27 August 2023 9:30 JST +09:00',
  end_time: '27 August 2023 13:00 JST +09:00'
)

am = TimeSlot.find_by(name: "具だくさんスライム＆光るタピオカパーティー☆彡")
am.options.where(category: [:extension, :k_extension, :arrival, :k_arrival]).destroy_all
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
filename = "todoroki.png"
slot_key = "production/slots/#{filename}"
am.image.attach(key: slot_key, io: File.open("app/assets/images/#{filename}"), filename: filename, content_type: 'image/png')

# Prod
filename = "todoroki.png"
slot_asset_key = "images/time_slots/summer_2023/#{filename}"
slot_key = "production/time_slots/#{filename}"
slot_image = client.get_object(bucket: bucket_name, key: slot_asset_key)
am.image.attach(key: slot_key, io: slot_image.body, filename: filename, content_type: 'image/png')

am.create_afternoon_slot(
  name: "親子で参加可能♪浴衣OK♡うちわ作り体験＆KidsUP夏祭り",
  category: :special,
  morning: false,
  start_time: '27 August 2023 15:00 JST +09:00',
  end_time: '27 August 2023 18:30 JST +09:00',
  event_id: am.event_id
)

pm = am.afternoon_slot
pm.options.destroy_all

# Toyocho

event = School.find_by(name: "東陽町").events.first

event.time_slots.create!(
  name: "水鉄砲合戦＆ビーチジオラマ",
  morning: true,
  category: :special,
  start_time: '2 September 2023 9:30 JST +09:00',
  end_time: '2 September 2023 13:00 JST +09:00'
)

am = TimeSlot.find_by(name: "水鉄砲合戦＆ビーチジオラマ")

# Local
filename = "toyocho.png"
slot_key = "production/slots/#{filename}"
am.image.attach(key: slot_key, io: File.open("app/assets/images/#{filename}"), filename: filename, content_type: 'image/png')

# Prod
filename = "toyocho.png"
slot_asset_key = "images/time_slots/summer_2023/#{filename}"
slot_key = "production/time_slots/#{filename}"
slot_image = client.get_object(bucket: bucket_name, key: slot_asset_key)
am.image.attach(key: slot_key, io: slot_image.body, filename: filename, content_type: 'image/png')

am.create_afternoon_slot(
  name: "貝殻ペンダント ＆ フレンチクレープ",
  category: :special,
  morning: false,
  start_time: '2 September 2023 15:00 JST +09:00',
  end_time: '2 September 2023 18:30 JST +09:00',
  event_id: am.event_id
)

pm = am.afternoon_slot
pm.options.where(category: [:departure, :k_departure]).destroy_all

# Yako

event = School.find_by(name: "矢向").events.first

event.time_slots.create!(
  name: "カワスイ 川崎水族館 遠足",
  morning: true,
  category: :special,
  start_time: '2 September 2023 9:30 JST +09:00',
  end_time: '2 September 2023 13:00 JST +09:00'
)

am = TimeSlot.find_by(name: "カワスイ 川崎水族館 遠足")
am.options.find_by(category: :meal).destroy

# Local
filename = "yako.png"
slot_key = "production/slots/#{filename}"
am.image.attach(key: slot_key, io: File.open("app/assets/images/#{filename}"), filename: filename, content_type: 'image/png')

# Prod
filename = "yako.png"
slot_asset_key = "images/time_slots/summer_2023/#{filename}"
slot_key = "production/time_slots/#{filename}"
slot_image = client.get_object(bucket: bucket_name, key: slot_asset_key)
am.image.attach(key: slot_key, io: slot_image.body, filename: filename, content_type: 'image/png')

am.create_afternoon_slot(
  name: "Kids UP縁日",
  category: :special,
  morning: false,
  start_time: '2 September 2023 15:00 JST +09:00',
  end_time: '2 September 2023 18:30 JST +09:00',
  event_id: am.event_id
)

# Shinjo

event = School.find_by(name: "武蔵新城").events.first

event.time_slots.create!(
  name: "宝探し&夏祭り",
  morning: true,
  category: :special,
  closed: true,
  start_time: '2 September 2023 9:30 JST +09:00',
  end_time: '2 September 2023 13:00 JST +09:00'
)

am = TimeSlot.find_by(name: "宝探し&夏祭り")
am.options.destroy_all

# Local
filename = "shinjo.png"
slot_key = "production/slots/#{filename}"
am.image.attach(key: slot_key, io: File.open("app/assets/images/#{filename}"), filename: filename, content_type: 'image/png')

# Prod
filename = "shinjo.png"
slot_asset_key = "images/time_slots/summer_2023/#{filename}"
slot_key = "production/time_slots/#{filename}"
slot_image = client.get_object(bucket: bucket_name, key: slot_asset_key)
am.image.attach(key: slot_key, io: slot_image.body, filename: filename, content_type: 'image/png')

am.create_afternoon_slot(
  name: "宝探し&夏祭り",
  category: :special,
  morning: false,
  start_time: '2 September 2023 15:00 JST +09:00',
  end_time: '2 September 2023 18:30 JST +09:00',
  event_id: am.event_id
)

# Shin-Urayasu

event = School.find_by(name: "新浦安").events.first

event.time_slots.create!(
  name: "KidsUP大夏祭り/時計作り",
  morning: true,
  category: :special,
  start_time: '2 September 2023 9:30 JST +09:00',
  end_time: '2 September 2023 13:00 JST +09:00'
)

am = TimeSlot.find_by(name: "KidsUP大夏祭り/時計作り")
am.options.destroy_all

# Local
filename = "shinurayasu.png"
slot_key = "production/slots/#{filename}"
am.image.attach(key: slot_key, io: File.open("app/assets/images/#{filename}"), filename: filename, content_type: 'image/png')

# Prod
filename = "shinurayasu.png"
slot_asset_key = "images/time_slots/summer_2023/#{filename}"
slot_key = "production/time_slots/#{filename}"
slot_image = client.get_object(bucket: bucket_name, key: slot_asset_key)
am.image.attach(key: slot_key, io: slot_image.body, filename: filename, content_type: 'image/png')

# Kamata

event = School.find_by(name: "蒲田駅前").events.first

event.time_slots.create!(
  name: "大人気アクティビティアンコールイベント",
  morning: true,
  category: :special,
  start_time: '26 August 2023 9:30 JST +09:00',
  end_time: '26 August 2023 13:00 JST +09:00'
)

am = TimeSlot.find_by(name: "大人気アクティビティアンコールイベント")

# Local
filename = "kamata.png"
slot_key = "production/slots/#{filename}"
am.image.attach(key: slot_key, io: File.open("app/assets/images/#{filename}"), filename: filename, content_type: 'image/png')

# Prod
filename = "kamata.png"
slot_asset_key = "images/time_slots/summer_2023/#{filename}"
slot_key = "production/time_slots/#{filename}"
slot_image = client.get_object(bucket: bucket_name, key: slot_asset_key)
am.image.attach(key: slot_key, io: slot_image.body, filename: filename, content_type: 'image/png')

am.create_afternoon_slot(
  name: "夏祭り@蒲田",
  category: :special,
  morning: false,
  start_time: '26 August 2023 15:00 JST +09:00',
  end_time: '26 August 2023 18:30 JST +09:00',
  event_id: am.event_id
)

# Minami Gyotoku

event = School.find_by(name: "南行徳").events.first

event.time_slots.create!(
  name: "親子参加型！サイエンスアイスクリームを作ろう♪",
  morning: true,
  category: :special,
  start_time: '2 September 2023 9:30 JST +09:00',
  end_time: '2 September 2023 13:00 JST +09:00'
)

am = TimeSlot.find_by(name: "親子参加型！サイエンスアイスクリームを作ろう♪")
am.options.destroy_all

# Local
filename = "gyotoku.png"
slot_key = "production/slots/#{filename}"
am.image.attach(key: slot_key, io: File.open("app/assets/images/#{filename}"), filename: filename, content_type: 'image/png')

# Prod
filename = "gyotoku.png"
slot_asset_key = "images/time_slots/summer_2023/#{filename}"
slot_key = "production/time_slots/#{filename}"
slot_image = client.get_object(bucket: bucket_name, key: slot_asset_key)
am.image.attach(key: slot_key, io: slot_image.body, filename: filename, content_type: 'image/png')

am.create_afternoon_slot(
  name: "親子参加型！サイエンスアイスクリームを作ろう♪",
  category: :special,
  morning: false,
  start_time: '2 September 2023 15:00 JST +09:00',
  end_time: '2 September 2023 18:30 JST +09:00',
  event_id: am.event_id
)

pm = am.afternoon_slot
pm.options.destroy_all

family_slots = [am, pm]
family_slots.each do |slot|
  slot.options.create!([
    {
      name: 'なし',
      category: :plusone,
      cost: 0
    },
    {
      name: '兄弟姉妹×1',
      category: :plusone,
      cost: 4_500
    },
    {
      name: '兄弟姉妹×2',
      category: :plusone,
      cost: 9_000
    },
    {
      name: '親×1',
      category: :plusone,
      cost: 1_500
    },
    {
      name: '親×2',
      category: :plusone,
      cost: 3_000
    },
    {
      name: '兄弟姉妹×1 + 親×1',
      category: :plusone,
      cost: 6_000
    }
  ])
end