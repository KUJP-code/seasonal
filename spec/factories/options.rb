# frozen_string_literal: true

FactoryBot.define do
  factory :option do
    name { Faker::Book.title }
    cost { 1000 }
    optionable { create(:time_slot) }
  end
end
