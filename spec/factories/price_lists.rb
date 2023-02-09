# frozen_string_literal: true

FactoryBot.define do
  factory :price_list do
    name { 'Test' }
    category { :member }
    courses do
      {
        1 => 4_216,
        5 => 18_700,
        10 => 33_000,
        15 => 49_500,
        20 => 66_000,
        25 => 82_500,
        30 => 99_000
      }
    end
  end
end
