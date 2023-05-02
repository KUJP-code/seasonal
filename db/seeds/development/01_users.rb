# Generate Japanese text
require 'faker/japanese'
Faker::Config.locale = :ja

# Creates my test accounts

admin = User.new(
          email: 'admin@gmail.com',
          password: 'adminadminadmin',
          first_name: Faker::Name.first_name,
          family_name: Faker::Name.last_name,
          kana_first: Faker::Name.first_name.kana,
          kana_family: Faker::Name.last_name.kana,
          role: :admin,
          address: Faker::Address.full_address,
          phone: Faker::PhoneNumber.phone_number,
          pin: '0000'
        )

admin.skip_confirmation_notification!
admin.save!
admin.confirm

am = User.new(
       email: 'am@gmail.com',
       password: 'ampasswordampassword',
       first_name: Faker::Name.first_name,
       family_name: Faker::Name.last_name,
       kana_first: Faker::Name.first_name.kana,
       kana_family: Faker::Name.last_name.kana,
       role: :area_manager,
       address: Faker::Address.full_address,
       phone: Faker::PhoneNumber.phone_number,
       pin: '0000'
    )

am.skip_confirmation_notification!
am.save!
am.confirm

sm = User.new(
    email: 'sm@gmail.com',
    password: 'smpasswordsmpassword',
    first_name: Faker::Name.first_name,
    family_name: Faker::Name.last_name,
    kana_first: Faker::Name.first_name.kana,
    kana_family: Faker::Name.last_name.kana,
    role: :school_manager,
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number,
    pin: '0000'
  )

sm.skip_confirmation_notification!
sm.save!
sm.confirm

customer = User.new(
    email: 'customer@gmail.com',
    password: 'customerpassword',
    first_name: Faker::Name.first_name,
    family_name: Faker::Name.last_name,
    kana_first: Faker::Name.first_name.kana,
    kana_family: Faker::Name.last_name.kana,
    role: :customer,
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number
  )

customer.skip_confirmation_notification!
customer.save!
customer.confirm

puts 'Created my test accounts'

User.find_by(role: 'area_manager').managed_areas.create!(name: "神奈川県")

puts 'Gave AM an area to manage'