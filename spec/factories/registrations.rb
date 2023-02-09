# frozen_string_literal: true

FactoryBot.define do
  factory :registration do
    child
    invoice

    factory :option_registration do
      registerable { create(:option) }
    end

    factory :slot_registration do
      registerable { create(:time_slot) }
    end
  end
end
