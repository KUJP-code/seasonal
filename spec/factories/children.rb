# frozen_string_literal: true

FactoryBot.define do
  factory :child do
    name { Faker::Name.name }
    katakana_name { Faker::Name.name }
    en_name { "B'rett-Tan ner" }
    birthday { Faker::Date.birthday(min_age: 2, max_age: 13) }
    ssid { |n| n }
    parent { create(:customer_user) }
    school { create(:school) }
  end
end
