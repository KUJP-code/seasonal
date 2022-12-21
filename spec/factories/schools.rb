# frozen_string_literal: true

FactoryBot.define do
  factory :school do
    name { Faker::Address.city }
    address { Faker::Address.full_address }
    phone { Faker::PhoneNumber.phone_number }
    area { create(:area) }
    manager { create(:sm_user) }
  end
end
