# frozen_string_literal: true

FactoryBot.define do
  factory :registration, class: 'Registration' do
    child
    factory :slot_reg do
      registerable factory: :time_slot
    end

    factory :opt_reg do
      registerable factory: :option
    end
  end
end
