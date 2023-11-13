# frozen_string_literal: true

require 'faker/japanese'
Faker::Config.locale = :ja

FactoryBot.define do
  factory :child do
    school
    allergies { 'なし' }
    category { Child.categories.keys.sample }
    en_name { 'Brett Tanner' }
    grade { Child.grades.keys.sample }
    katakana_name { Faker::Name.name.kana }
    name { Faker::Name.name }
    photos { Child.photos.keys.sample }
  end
end
