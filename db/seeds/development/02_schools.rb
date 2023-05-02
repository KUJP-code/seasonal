Area.first.schools.create!([
  {
    name: '田園調布雪谷'
  },
  {
    name: '長原'
  },
  {
    name: '池上'
  },
  {
    name: '蒲田駅前'
  },
  {
    name: '門前仲町'
  },
  {
    name: '大森'
  },
  {
    name: '東陽町'
  },
  {
    name: 'オンラインコース'
  },
  {
    name: 'りんかい東雲'
  },
  {
    name: '戸越'
  },
  {
    name: '馬込'
  },
  {
    name: '晴海'
  },
  {
    name: '成城'
  },
  {
    name: '大島'
  },
  {
    name: '大井'
  },
  {
    name: '早稲田'
  },
  {
    name: '四谷'
  },
  {
    name: '三鷹'
  },
  {
    name: '新浦安'
  },
  {
    name: '新川崎'
  },
  {
    name: '等々力'
  },
  {
    name: '矢向'
  },
  {
    name: '海浜幕張'
  },
  {
    name: '天王町'
  },
  {
    name: '北品川'
  },
  {
    name: '二俣川'
  },
  {
    name: '南町田グランベリーパーク'
  },
  {
    name: '武蔵小杉'
  },
  {
    name: '赤羽'
  },
  {
    name: '溝の口'
  },
  {
    name: '武蔵新城'
  },
  {
    name: '大倉山'
  },
  {
    name: '鷺宮'
  },
  {
    name: '南行徳'
  }
])

School.find_by(name: '大倉山').managers << User.find_by(role: 'school_manager')

User.find_by(role: 'customer').children.create!([
  {
    first_name: Faker::Name.first_name,
    family_name: Faker::Name.last_name,
    kana_first: Faker::Name.first_name.kana,
    kana_family: Faker::Name.last_name.kana,
    en_name: %w[Timmy Sally Billy Sarah Viktoria Brett Leroy].sample,
    birthday: Faker::Date.birthday(min_age: 2, max_age: 13),
    ssid: Faker::Number.unique.number,
    ele_school_name: Faker::GreekPhilosophers.name,
    photos: 'はい',
    allergies: 'ice cream',
    school: School.find_by(name: '大倉山'),
    category: :internal,
    needs_hat: false,
    received_hat: true
  },
  {
    first_name: Faker::Name.first_name,
    family_name: Faker::Name.last_name,
    kana_first: Faker::Name.first_name.kana,
    kana_family: Faker::Name.last_name.kana,
    en_name: %w[Timmy Sally Billy Sarah Viktoria Brett Leroy].sample,
    birthday: Faker::Date.birthday(min_age: 2, max_age: 13),
    ssid: Faker::Number.unique.number,
    ele_school_name: Faker::GreekPhilosophers.name,
    photos: 'いいえ',
    allergies: 'ice cream',
    school: School.find_by(name: '大倉山'),
    category: :internal,
    needs_hat: false,
    received_hat: true
  }
])

puts 'Put Yoshi in charge of Okurayama and gave the test customer 2 kids who go there'

translation_hash = {
  '田園調布雪谷' => 'd-yukigaya@kids-up.jp',
  '蒲田駅前' => 'j-kamata@kids-up.jp',
  '池上' => 'ikegami@kids-up.jp',
  '東陽町' => 'toyocho@kids-up.jp',
  '長原' => 'nagahara@kids-up.jp',
  '門前仲町' => 'monnaka@kids-up.jp',
  '戸越' => 'togoshi@kids-up.jp',
  '成城' => 'seijo@kids-up.jp',
  '大森' => 'omori@kids-up.jp',
  '早稲田' => 'waseda@kids-up.jp',
  'りんかい東雲' => 'rinkaishinonome@kids-up.jp',
  '新川崎' => 'shin-kawasaki@kids-up.jp',
  '等々力' => 'todoroki@kids-up.jp',
  '大島' => 'ojima@kids-up.jp',
  '三鷹' => 'mitaka@kids-up.jp',
  '二俣川' => 'futamatagawa@kids-up.jp',
  '新浦安' => 'shin-urayasu@kids-up.jp',
  '天王町' => 'tennocho@kids-up.jp',
  '南町田グランベリーパーク' => 'minami-machida@kids-up.jp',
  '大井' => 'kidsup-oi@kids-up.jp',
  '晴海' => 'harumi@kids-up.jp',
  '四谷' => 'yotsuya@kids-up.jp',
  '赤羽' => 'akabane@kids-up.jp',
  '北品川' => 'kitashinagawa@kids-up.jp',
  '溝の口' => 'mizonokuchi@kids-up.jp',
  '矢向' => 'yako@kids-up.jp',
  '南行徳' => 'minamigyotoku@kids-up.jp',
  '鷺宮' => 'saginomiya@kids-up.jp',
  '馬込' => 'magome@kids-up.jp',
  '大倉山' => 'ookurayama@kids-up.jp',
  '武蔵新城' => 'musashishinjo@kids-up.jp',
  '武蔵小杉' => 'musashikosugi@kids-up.jp',
  'オンラインコース' => 'online@kids-up.jp',
  '海浜幕張' => 'daiba@kids-up.jp'
}

School.all.each do |school|
  sm = User.new(
    email: translation_hash[school.name],
    password: "schoolschool",
    name: "#{school.name}",
    kana_first: Faker::Name.first_name.kana,
    kana_family: Faker::Name.last_name.kana,
    role: :school_manager,
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number,
    pin: '0000'
  )
  sm.skip_confirmation_notification!
  sm.save!

  school.managers << sm
end

puts 'Added schools and created a manager for each'

User.all.each do |user|
  user.confirm
end

puts 'Confirm emails for all users'