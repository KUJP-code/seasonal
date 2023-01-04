# frozen_string_literal: true

FactoryBot.define do
  factory :school do
    name { Faker::Address.city }
    address { Faker::Address.full_address }
    phone { Faker::PhoneNumber.phone_number }
    area { create(:area) }

    trait :managed do
      managers { [create(:sm_user)] }
    end

    factory :managed_school, traits: [:managed]
  end
end
