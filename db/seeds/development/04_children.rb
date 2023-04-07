User.customers.each do |customer_user|
  school = School.find(rand(1..3))
  customer_user.children.create!([
    {
      first_name: Faker::Name.first_name,
      family_name: Faker::Name.last_name,
      kana_first: Faker::Name.first_name,
      kana_family: Faker::Name.last_name,
      en_name: %w[Timmy Sally Billy Sarah Viktoria Brett].sample,
      birthday: Faker::Date.birthday(min_age: 2, max_age: 13),
      ssid: Faker::Number.unique.number,
      ele_school_name: Faker::GreekPhilosophers.name,
      post_photos: true,
      allergies: 'peanuts',
      grade: '年中',
      category: :external,
      school: school
    },
    {
      first_name: Faker::Name.first_name,
      family_name: Faker::Name.last_name,
      kana_first: Faker::Name.first_name,
      kana_family: Faker::Name.last_name,
      en_name: %w[Timmy Sally Billy Sarah Viktoria Brett].sample,
      birthday: Faker::Date.birthday(min_age: 2, max_age: 13),
      ssid: Faker::Number.unique.number,
      ele_school_name: Faker::GreekPhilosophers.name,
      allergies: 'peanuts',
      grade: '小４',
      category: :reservation,
      school: school
    }
  ])
end

puts 'Gave each customer 2 children'

Child.create!(
  first_name: Faker::Name.first_name,
  family_name: Faker::Name.last_name,
  kana_first: Faker::Name.first_name,
  kana_family: Faker::Name.last_name,
  en_name: %w[Timmy Sally Billy Sarah Viktoria Brett].sample,
  birthday: 'Wed, 20 Feb 2020',
  ssid: 1,
  ele_school_name: Faker::GreekPhilosophers.name,
  post_photos: true,
  allergies: 'peanuts',
)

puts "Created an orphaned child to test adding parent's children with"

Child.all.each do |child|
  child.create_regular_schedule(
    monday: [true, false].sample,
    tuesday: [true, false].sample,
    wednesday: [true, false].sample,
    thursday: [true, false].sample,
    friday: [true, false].sample
  )
end

puts 'Created a random regular schedule for each child'