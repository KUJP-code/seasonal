# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    name { Faker::JapaneseMedia::StudioGhibli.movie }
    description { Faker::JapaneseMedia::StudioGhibli.quote }
    start_date { Faker::Time.forward(days: 5) }
    end_date { Faker::Date.between(from: 10.days.from_now, to: 15.days.from_now) }
    school { create(:school) }
    member_price { create(:member_price) }
    non_member_price { create(:non_member_price) }
  end
end
