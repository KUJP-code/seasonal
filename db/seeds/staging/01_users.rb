# Generate Japanese text
require 'faker/japanese'
Faker::Config.locale = :ja

# Creates my test accounts

admin = User.new(
    email: 'live_admin@gmail.com',
    password: ENV['ADMIN_PASS'],
    first_name: Faker::Name.first_name,
    family_name: Faker::Name.last_name,
    kana_first: Faker::Name.first_name.kana,
    kana_family: Faker::Name.last_name.kana,
    role: :admin,
    address: Faker::Address.full_address,
    postcode: Faker::Address.postcode,
    prefecture: Faker::Address.state,
    phone: Faker::PhoneNumber.phone_number,
    pin: '0000'
  )

admin.skip_confirmation_notification!
admin.save!
admin.confirm

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

User.find_by(role: 'area_manager').managed_areas.create!(name: "神奈川県")