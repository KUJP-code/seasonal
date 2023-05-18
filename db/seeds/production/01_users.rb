# Generate Japanese text
require 'faker/japanese'
Faker::Config.locale = :ja

# Create test accounts and area/school

am = User.new(
  email: 'live_am@gmail.com',
  password: ENV['AM_PASS'],
  first_name: Faker::Name.first_name,
  family_name: Faker::Name.last_name,
  kana_first: Faker::Name.first_name.kana,
  kana_family: Faker::Name.last_name.kana,
  role: :area_manager,
  address: Faker::Address.full_address,
  postcode: Faker::Address.postcode,
  prefecture: Faker::Address.state,
  phone: Faker::PhoneNumber.phone_number,
  pin: '0000'
)

am.skip_confirmation_notification!
am.save!
am.confirm

sm = User.new(
  email: 'live_sm@gmail.com',
  password: ENV['SM_PASS'],
  first_name: Faker::Name.first_name,
  family_name: Faker::Name.last_name,
  kana_first: Faker::Name.first_name.kana,
  kana_family: Faker::Name.last_name.kana,
  role: :school_manager,
  address: Faker::Address.full_address,
  postcode: Faker::Address.postcode,
  prefecture: Faker::Address.state,
  phone: Faker::PhoneNumber.phone_number,
  pin: '0000'
)

sm.skip_confirmation_notification!
sm.save!
sm.confirm

customer = User.new(
  email: 'live_customer@gmail.com',
  password: ENV['CUSTOMER_PASS'],
  first_name: Faker::Name.first_name,
  family_name: Faker::Name.last_name,
  kana_first: Faker::Name.first_name.kana,
  kana_family: Faker::Name.last_name.kana,
  role: :customer,
  address: Faker::Address.full_address,
  postcode: Faker::Address.postcode,
  prefecture: Faker::Address.state,
  phone: Faker::PhoneNumber.phone_number
)

customer.skip_confirmation_notification!
customer.save!
customer.confirm

User.find_by(role: 'area_manager').managed_areas.create!(name: 'Test')
Area.first.schools.create!(name: 'Test')
School.first.managers << User.find_by(role: 'school_manager')

translation_hash = {
  'Test' => 'bretttanner171@gmail.com',
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
    password: ENV['TEMP_PASS'],
    name: "#{school.name}",
    katakana_name: Faker::Name.name.kana,
    role: :school_manager,
    address: Faker::Address.full_address,
    postcode: Faker::Address.postcode,
    prefecture: Faker::Address.state,
    phone: Faker::PhoneNumber.phone_number,
    pin: Faker::Number.number(digits: 4)
  )
  sm.skip_confirmation_notification!
  sm.save!

  school.managers << sm
end

User.all.each do |user|
  user.confirm
end