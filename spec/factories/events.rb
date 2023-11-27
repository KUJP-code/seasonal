# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    member_prices factory: :member_prices
    non_member_prices factory: :non_member_prices
    school
    name { 'Test Event' }
    start_date { 1.day.from_now }
    end_date { 2.days.from_now }
  end
end
