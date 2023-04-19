# Creates my test accounts

User.create!([
  {
    email: 'admin@gmail.com',
    password: ENV['ADMIN_PASS'],
    first_name: Faker::Name.first_name,
    family_name: Faker::Name.last_name,
    kana_first: Faker::Name.first_name,
    kana_family: Faker::Name.last_name,
    role: :admin,
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number,
    pin: '0000'
  },
  {
    email: 'am@gmail.com',
    password: ENV['AM_PASS'],
    first_name: Faker::Name.first_name,
    family_name: Faker::Name.last_name,
    kana_first: Faker::Name.first_name,
    kana_family: Faker::Name.last_name,
    role: :area_manager,
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number,
    pin: '0000'
  },
  {
    email: 'sm@gmail.com',
    password: ENV['SM_PASS'],
    first_name: Faker::Name.first_name,
    family_name: Faker::Name.last_name,
    kana_first: Faker::Name.first_name,
    kana_family: Faker::Name.last_name,
    role: :school_manager,
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number,
    pin: '0000'
  },
  {
    email: 'customer@gmail.com',
    password: ENV['CUSTOMER_PASS'],
    first_name: Faker::Name.first_name,
    family_name: Faker::Name.last_name,
    kana_first: Faker::Name.first_name,
    kana_family: Faker::Name.last_name,
    role: :customer,
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number
  }
])

User.find_by(role: 'area_manager').managed_areas.create!(name: "神奈川県")