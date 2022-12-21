# frozen_string_literal: true

FactoryBot.define do
  factory :area do
    name { Faker::Address.city }
    manager { create(:am_user) }
  end
end
