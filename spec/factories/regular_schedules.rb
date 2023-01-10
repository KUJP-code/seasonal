# frozen_string_literal: true

FactoryBot.define do
  factory :regular_schedule do
    monday { true }
    tuesday { true }
    wednesday { true }
    thursday { true }
    friday { true }
  end
end
