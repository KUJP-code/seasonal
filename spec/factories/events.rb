# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    name { Faker::JapaneseMedia::StudioGhibli.movie }
    start_date { Faker::Time.forward(days: 5) }
    end_date { Faker::Date.between(from: 10.days.from_now, to: 15.days.from_now) }
    school { create(:school) }
    member_prices { create(:member_prices) }
    non_member_prices { create(:non_member_prices) }
  end
end
