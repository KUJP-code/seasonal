School.all.each do |school|
  10.times do
    parent = User.new(
      first_name: Faker::Name.first_name,
      family_name: Faker::Name.last_name,
      kana_first: Faker::Name.first_name.kana,
      kana_family: Faker::Name.last_name.kana,
      email: Faker::Internet.unique.email,
      password: Faker::Internet.password(min_length: 10),
      address: Faker::Address.full_address,
      postcode: Faker::Address.postcode,
      prefecture: Faker::Address.state,
      phone: Faker::PhoneNumber.phone_number
    )

    parent.skip_confirmation_notification!
    parent.save!

    2.times do
      school.children.create!(
        first_name: Faker::Name.first_name,
        family_name: Faker::Name.last_name,
        kana_first: Faker::Name.first_name.kana,
        kana_family: Faker::Name.last_name.kana,
        en_name: %w[Timmy Sally Billy Sarah Viktoria Brett Leroy].sample,
        birthday: Faker::Date.birthday(min_age: 2, max_age: 13),
        ssid: Faker::Number.unique.number,
        ele_school_name: Faker::GreekPhilosophers.name,
        photos: 'OK',
        allergies: 'peanuts',
        parent: parent,
        category: :internal,
        first_seasonal: false,
        received_hat: true
      )
    end
  end
end

School.all.each do |school|
  school.children.create!(
    first_name: Faker::Name.first_name,
    family_name: Faker::Name.last_name,
    kana_first: Faker::Name.first_name.kana,
    kana_family: Faker::Name.last_name.kana,
    en_name: %w[Timmy Sally Billy Sarah Viktoria Brett].sample,
    birthday: 'Wed, 20 Feb 2020',
    ssid: Faker::Number.unique.number(digits: 5),
    ele_school_name: Faker::GreekPhilosophers.name,
    photos: 'NG',
    allergies: 'pizza',
    parent: nil
  )
end

Child.all.each do |child|
  child.create_regular_schedule(
    monday: [true, false].sample,
    tuesday: [true, false].sample,
    wednesday: [true, false].sample,
    thursday: [true, false].sample,
    friday: [true, false].sample
  )
end
