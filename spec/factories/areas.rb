# frozen_string_literal: true

FactoryBot.define do
  factory :area do
    name { Faker::Address.city }

    trait :managed do
      managers { [create(:am_user)] }
    end

    factory :managed_area, traits: [:managed]
  end
end
