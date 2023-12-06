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

    factory :admin do
      role { 'admin' }
    end

    factory :statistician do
      role { 'statistician' }
    end

    factory :area_manager do
      role { 'area_manager' }
    end

    factory :school_manager do
      role { 'school_manager' }
    end

    factory :customer do
      role { 'customer' }
    end
  end
end
