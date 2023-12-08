# frozen_string_literal: true

FactoryBot.define do
  factory :inquiry do
    school
    parent_name { Faker::Name.name }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }
  end
end
