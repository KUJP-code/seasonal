# frozen_string_literal: true

FactoryBot.define do
  factory :option, class: 'Option' do
    name { 'Option' }
    cost { 10 }
    factory :slot_option do
      optionable factory: :time_slot
    end

    factory :event_option do
      optionable factory: :event
      category { :event }
    end
  end
end
