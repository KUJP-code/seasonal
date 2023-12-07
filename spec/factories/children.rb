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

    factory :form_child do
      en_name { 'Brett Tanner' }
      first_name { 'Brett' }
      family_name { 'Tanner' }
      katakana_name { 'ブレットタナ' }
      kana_first { 'ブレット' }
      kana_family { 'タナ' }
    end

    factory :internal_child do
      category { 'internal' }
    end

    factory :external_child do
      category { 'external' }
    end
  end
end
