# frozen_string_literal: true

FactoryBot.define do
  factory :adjustment do
    invoice
    change { -5000 }
    reason { Faker::Lorem.sentence(word_count: 10) }
  end
end
