# frozen_string_literal: true

FactoryBot.define do
  factory :child do
    ja_first_name { Faker::Name.first_name }
    ja_family_name { Faker::Name.last_name }
    en_name { "B'rett-Tan ner" }
    birthday { Faker::Date.birthday(min_age: 2, max_age: 13) }
    ssid { |n| n }
    ele_school_name { Faker::GreekPhilosophers.name }
    post_photos { true }
    allergies { 'Augmentum, penicillin, peanuts' }
    parent { create(:customer_user) }
    school { create(:school) }
  end
end
