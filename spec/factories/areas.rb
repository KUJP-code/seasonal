# frozen_string_literal: true

FactoryBot.define do
  factory :area do
    name { Faker::Address.city }
  end
end
