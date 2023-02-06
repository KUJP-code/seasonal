# frozen_string_literal: true

FactoryBot.define do
  factory :option do
    name { Faker::Book.title }
    description { Faker::Lorem.sentence(word_count: 10) }
    cost { 4000 }
    optionable { create(:time_slot) }
  end
end
