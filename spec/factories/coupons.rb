# frozen_string_literal: true

FactoryBot.define do
  factory :coupon do
    code { Faker::Code.asin }
    name { Faker::Games::LeagueOfLegends.champion }
    discount { 0.33 }
    combinable { false }

    trait :slot do
      couponable { create(:time_slot) }
    end

    trait :option do
      couponable { create(:option) }
    end

    factory :slot_coupon, traits: [:slot]
    factory :option_coupon, traits: [:option]
  end
end
