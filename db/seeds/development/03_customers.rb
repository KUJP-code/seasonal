School.all.each do |school|
  school.customers.create!([
    {
      first_name: Faker::Name.first_name,
      family_name: Faker::Name.last_name,
      kana_first: Faker::Name.first_name,
      kana_family: Faker::Name.last_name,
      email: Faker::Internet.unique.email,
      password: Faker::Internet.password(min_length: 10),
      address: Faker::Address.full_address,
      phone: Faker::PhoneNumber.phone_number
    },
    {
      first_name: Faker::Name.first_name,
      family_name: Faker::Name.last_name,
      kana_first: Faker::Name.first_name,
      kana_family: Faker::Name.last_name,
      email: Faker::Internet.unique.email,
      password: Faker::Internet.password(min_length: 10),
      address: Faker::Address.full_address,
      phone: Faker::PhoneNumber.phone_number
    }
  ])
end

puts 'Added 2 Faker customers to each school, plus my test customer to the last one'