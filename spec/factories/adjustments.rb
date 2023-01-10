# frozen_string_literal: true

FactoryBot.define do
  factory :adjustment do
    change { -2000 }
    reason { Faker::Lorem.sentence(word_count: 10) }
    email_sent { false }
  end
end
