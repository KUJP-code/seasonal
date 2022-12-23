# frozen_string_literal: true

FactoryBot.define do
  factory :child do
    birthday { Faker::Date.birthday(min_age: 2, max_age: 13) }
    allergies { 'Augmentum, penicillin, peanuts' }
    parent { create(:customer_user) }
    school { create(:school) }
  end
end
