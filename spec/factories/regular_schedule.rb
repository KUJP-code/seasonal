# frozen_string_literal: true

FactoryBot.define do
  factory :regular_schedule do
    child
    monday { false }
    tuesday { false }
    wednesday { false }
    thursday { false }
    friday { false }
  end
end
