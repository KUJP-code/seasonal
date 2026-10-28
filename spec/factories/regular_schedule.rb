# frozen_string_literal: true

FactoryBot.define do
  factory :regular_schedule do
    child
    month { Date.current.beginning_of_month }
    monday { false }
    tuesday { false }
    wednesday { false }
    thursday { false }
    friday { false }
  end
end
