# This file is last to simulate fresh users

non_member = User.new(
  email: 'non_member@gmail.com',
  password: 'nonmembernon',
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
  first_seasonal: true,
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
  photos: 'OK',
  allergies: 'spaghetti',
  grade: '小４',
  category: :external,
  first_seasonal: true,
  received_hat: false,
  school: School.all.find_by(name: '大倉山')
}
])

member = User.new(
  email: 'member@gmail.com',
  password: 'membermembermember',
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
    photos: 'OK',
    first_seasonal: false,
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
    first_seasonal: false,
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

puts 'Created test users and their children for only member children and only non-member children, with no registrations'