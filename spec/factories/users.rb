FactoryBot.define do
  factory :user do
    id { |n| n }
    # name { Faker::Name.name }
    # username { Faker::Internet.unique.username }
    email { Faker::Internet.unique.email }
    password { Faker::Internet.password(min_length: 10) }
  end
end