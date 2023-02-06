# frozen_string_literal: true

FactoryBot.define do
  factory :registration do
    trait :option do
      registerable { create(:option) }
    end

    trait :time_slot do
      registerable { create(:time_slot) }
    end

    factory :option_registration, traits: [:option]
    factory :slot_registration, traits: [:time_slot]
  end
end
