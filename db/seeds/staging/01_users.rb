# Generate Japanese text
require 'faker/japanese'
Faker::Config.locale = :ja

# Creates my test accounts

User.create!([
  {
    email: 'live_admin@gmail.com',
    password: ENV['ADMIN_PASS'],
    first_name: Faker::Name.first_name,
    family_name: Faker::Name.last_name,
    kana_first: Faker::Name.first_name.kana,
    kana_family: Faker::Name.last_name.kana,
    role: :admin,
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number,
    pin: '0000'
  },
  {
    email: 'live_am@gmail.com',
    password: ENV['AM_PASS'],
    first_name: Faker::Name.first_name,
    family_name: Faker::Name.last_name,
    kana_first: Faker::Name.first_name.kana,
    kana_family: Faker::Name.last_name.kana,
    role: :area_manager,
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number,
    pin: '0000'
  },
  {
    email: 'live_sm@gmail.com',
    password: ENV['SM_PASS'],
    first_name: Faker::Name.first_name,
    family_name: Faker::Name.last_name,
    kana_first: Faker::Name.first_name.kana,
    kana_family: Faker::Name.last_name.kana,
    role: :school_manager,
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number,
    pin: '0000'
  },
  {
    email: 'live_customer@gmail.com',
    password: ENV['CUSTOMER_PASS'],
    first_name: Faker::Name.first_name,
    family_name: Faker::Name.last_name,
    kana_first: Faker::Name.first_name.kana,
    kana_family: Faker::Name.last_name.kana,
    role: :customer,
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number
  }
])

User.find_by(role: 'area_manager').managed_areas.create!(name: "神奈川県")