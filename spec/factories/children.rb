# frozen_string_literal: true

FactoryBot.define do
  factory :child do
    ja_first_name { Faker::Name.first_name }
    ja_family_name { Faker::Name.last_name }
    katakana_name { Faker::Name.name.kana }
    en_name { "B'rett-Tan ner" }
    birthday { Faker::Date.birthday(min_age: 2, max_age: 13) }
    ssid { |n| n }
    parent { create(:customer_user) }
    school { create(:school) }
  end
end
