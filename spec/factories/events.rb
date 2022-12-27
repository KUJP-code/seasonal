FactoryBot.define do
  factory :event do
    name { Faker::JapaneseMedia::StudioGhibli.movie }
    description { Faker::JapaneseMedia::StudioGhibli.quote }
    start_date { Faker::Date.between(from: 5.days.from_now, to: 10.days.from_now) }
    end_date { Faker::Date.between(from: 12.days.from_now, to: 30.days.from_now) }
    school { create(:school) }
  end
end
