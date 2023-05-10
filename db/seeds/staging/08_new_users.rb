# This file is last to simulate fresh users

non_member = User.new(
  email: 'non_member@gmail.com',
  password: ENV['NON_MEMBER_PASS'],
  first_name: Faker::Name.first_name,
  family_name: Faker::Name.last_name,
  kana_first: Faker::Name.first_name.kana,
  kana_family: Faker::Name.last_name.kana,
  role: :customer,
  address: Faker::Address.full_address,
  phone: Faker::PhoneNumber.phone_number
)

non_member.skip_confirmation_notification!
non_member.save!
non_member.confirm

non_member.children.create!([
  {
    first_name: Faker::Name.first_name,
    family_name: Faker::Name.last_name,
    kana_first: Faker::Name.first_name.kana,
    kana_family: Faker::Name.last_name.kana,
    en_name: %w[Timmy Sally Billy Sarah Viktoria Brett Leroy].sample,
    birthday: Faker::Date.birthday(min_age: 2, max_age: 13),
    ssid: Faker::Number.unique.number,
    ele_school_name: Faker::GreekPhilosophers.name,
    allergies: 'pizza',
    grade: '年中',
    category: :external,
    needs_hat: true,
    received_hat: false,
    school: School.all.find_by(name: '大倉山')
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
    photos: 'はい',
    allergies: 'spaghetti',
    grade: '小４',
    category: :external,
    needs_hat: true,
    received_hat: false,
    school: School.all.find_by(name: '大倉山')
  }
])

member = User.new(
  email: 'member@gmail.com',
  password: ENV['MEMBER_PASS'],
  first_name: Faker::Name.first_name,
  family_name: Faker::Name.last_name,
  kana_first: Faker::Name.first_name.kana,
  kana_family: Faker::Name.last_name.kana,
  role: :customer,
  address: Faker::Address.full_address,
  phone: Faker::PhoneNumber.phone_number
)

member.skip_confirmation_notification!
member.save!
member.confirm

member.children.create!([
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
    needs_hat: false,
    allergies: 'milk',
    grade: '年中',
    category: 'internal',
    school: School.all.find_by(name: '大倉山')
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
    needs_hat: false,
    allergies: 'milk',
    grade: '小４',
    category: 'internal',
    school: School.all.find_by(name: '大倉山')
  }
])

member.children.each do |child|
child.create_regular_schedule!(
  monday: true,
  tuesday: false,
  wednesday: true,
  thursday: false,
  friday: false
)
end
