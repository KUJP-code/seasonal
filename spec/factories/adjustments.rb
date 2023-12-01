# frozen_string_literal: true

FactoryBot.define do
  factory :adjustment do
    invoice
    reason { 'Test reason' }
    change { 0 }
  end
end
