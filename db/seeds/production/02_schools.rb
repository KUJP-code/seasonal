Area.create!([
  {
    name: '飯森エリア'
  },
  {
    name: '阿部エリア'
  },
  {
    name: '小堀エリア'
  },
  {
    name: '田中エリア'
  }
])

am_one = Area.find_by(name: '飯森エリア').managers.new(
  email: 'e-iimori@kids-up.jp',
  password: ENV['TEMP_PASS'],
  name: '飯森',
  katakana_name: Faker::Name.name.kana,
  role: :area_manager,
  address: Faker::Address.full_address,
  postcode: Faker::Address.postcode,
  prefecture: Faker::Address.state,
  phone: Faker::PhoneNumber.phone_number,
  pin: Faker::Number.number(digits: 4)
)

am_one.skip_confirmation_notification!
am_one.save!
am_one.confirm

am_two = Area.find_by(name: '阿部エリア').managers.new(
  email: 'k-abe@kids-up.jp',
  password: ENV['TEMP_PASS'],
  name: '阿部',
  katakana_name: Faker::Name.name.kana,
  role: :area_manager,
  address: Faker::Address.full_address,
  postcode: Faker::Address.postcode,
  prefecture: Faker::Address.state,
  phone: Faker::PhoneNumber.phone_number,
  pin: Faker::Number.number(digits: 4)
)

am_two.skip_confirmation_notification!
am_two.save!
am_two.confirm

am_three = Area.find_by(name: '小堀エリア').managers.new(
  email: 'y-kobori@kids-up.jp',
  password: ENV['TEMP_PASS'],
  name: '小堀',
  katakana_name: Faker::Name.name.kana,
  role: :area_manager,
  address: Faker::Address.full_address,
  postcode: Faker::Address.postcode,
  prefecture: Faker::Address.state,
  phone: Faker::PhoneNumber.phone_number,
  pin: Faker::Number.number(digits: 4)
)

am_three.skip_confirmation_notification!
am_three.save!
am_three.confirm

am_four = Area.find_by(name: '田中エリア').managers.new(
  email: 'm-tanaka@kids-up.jp',
  password: ENV['TEMP_PASS'],
  name: '田中',
  katakana_name: Faker::Name.name.kana,
  role: :area_manager,
  address: Faker::Address.full_address,
  postcode: Faker::Address.postcode,
  prefecture: Faker::Address.state,
  phone: Faker::PhoneNumber.phone_number,
  pin: Faker::Number.number(digits: 4)
)

am_four.skip_confirmation_notification!
am_four.save!
am_four.confirm


School.create!([
  {
    name: 'Test',
    area: Area.find_by(name: "Test")
  },
  {
    name: 'オンラインコース',
    area: Area.find_by(name: "Test")
  },
  {
    name: '田園調布雪谷',
    area: Area.find_by(name: '阿部エリア')
  },
  {
    name: '蒲田駅前',
    area: Area.find_by(name: '阿部エリア')
  },
  {
    name: '東陽町',
    area: Area.find_by(name: '小堀エリア')
  },
  {
    name: '池上',
    area: Area.find_by(name: '阿部エリア')
  },
  {
    name: '長原',
    area: Area.find_by(name: '飯森エリア')
  },
  {
    name: '門前仲町',
    area: Area.find_by(name: '小堀エリア')
  },
  {
    name: '戸越',
    area: Area.find_by(name: '飯森エリア')
  },
  {
    name: '成城',
    area: Area.find_by(name: '飯森エリア')
  },
  {
    name: '大森',
    area: Area.find_by(name: '阿部エリア')
  },
  {
    name: '早稲田',
    area: Area.find_by(name: '飯森エリア')
  },
  {
    name: 'りんかい東雲',
    area: Area.find_by(name: '小堀エリア')
  },
  {
    name: '新川崎',
    area: Area.find_by(name: '阿部エリア')
  },
  {
    name: '等々力',
    area: Area.find_by(name: '飯森エリア')
  },
  {
    name: '大島',
    area: Area.find_by(name: '小堀エリア')
  },
  {
    name: '三鷹',
    area: Area.find_by(name: '飯森エリア')
  },
  {
    name: '二俣川',
    area: Area.find_by(name: '阿部エリア')
  },
  {
    name: '新浦安',
    area: Area.find_by(name: '小堀エリア')
  },
  {
    name: '天王町',
    area: Area.find_by(name: '阿部エリア')
  },
  {
    name: '南町田グランベリーパーク',
    area: Area.find_by(name: '阿部エリア')
  },
  {
    name: '大井',
    area: Area.find_by(name: '小堀エリア')
  },
  {
    name: '晴海',
    area: Area.find_by(name: '小堀エリア')
  },
  {
    name: '四谷',
    area: Area.find_by(name: '飯森エリア')
  },
  {
    name: '赤羽',
    area: Area.find_by(name: '飯森エリア')
  },
  {
    name: '北品川',
    area: Area.find_by(name: '小堀エリア')
  },
  {
    name: '溝の口',
    area: Area.find_by(name: '阿部エリア')
  },
  {
    name: '矢向',
    area: Area.find_by(name: '阿部エリア')
  },
  {
    name: '南行徳',
    area: Area.find_by(name: '小堀エリア')
  },
  {
    name: '鷺宮',
    area: Area.find_by(name: '飯森エリア')
  },
  {
    name: '馬込',
    area: Area.find_by(name: '飯森エリア')
  },
  {
    name: '大倉山',
    area: Area.find_by(name: '田中エリア')
  },
  {
    name: '武蔵新城',
    area: Area.find_by(name: '田中エリア')
  },
  {
    name: '武蔵小杉',
    area: Area.find_by(name: '田中エリア')
  }
])
