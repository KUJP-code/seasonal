# frozen_string_literal: true

FactoryBot.define do
  factory :recruit_application do
    role { 'sm' }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }
    full_name { Faker::Name.name }
    date_of_birth { Date.new(1990, 1, 1) }
    full_address { Faker::Address.full_address }
    privacy_policy_consent { true }

    trait :native do
      role { 'native' }
      reason_for_application { 'I enjoy teaching and child development.' }
      work_visa_status { 'Yes' }
    end
  end
end
