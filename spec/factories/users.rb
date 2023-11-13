# frozen_string_literal: true

require 'faker/japanese'
Faker::Config.locale = :ja

FactoryBot.define do
  factory :user do
    address { Faker::Address.street_address }
    email { Faker::Internet.email }
    katakana_name { Faker::Name.name.kana }
    name { Faker::Name.name }
    password { Faker::Internet.password(min_length: 10) }
    phone { Faker::PhoneNumber.phone_number }
    postcode { Faker::Address.postcode }
    prefecture { Faker::Address.state }
  end
end
