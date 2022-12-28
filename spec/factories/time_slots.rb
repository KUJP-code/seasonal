# frozen_string_literal: true

FactoryBot.define do
  factory :time_slot do
    name { Faker::Games::LeagueOfLegends.champion }
    start_time { Faker::Time.forward(days: 5) }
    end_time { Faker::Date.between(from: 10.days.from_now, to: 15.days.from_now) }
    description { Faker::Lorem.sentence(word_count: 10) }
    cost { 8000 }
    event { create(:event) }
  end
end
