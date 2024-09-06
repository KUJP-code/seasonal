# frozen_string_literal: true

FactoryBot.define do
  factory :time_slot do
    name { 'Test Time Slot' }
    event
    start_time { 1.hour.from_now }
    end_time { 2.hours.from_now }

    trait :morning do
      morning { true }
    end

    trait :afternoon do
      morning { false }
    end
  end
end
