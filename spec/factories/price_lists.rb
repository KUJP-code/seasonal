# frozen_string_literal: true

FactoryBot.define do
  factory :price_list do
    name { 'Test' }
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

    factory :member_price do
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

    factory :non_member_price do
      courses do
        {
          1 => 6_600,
          5 => 30_000,
          10 => 55_000,
          15 => 80_000,
          20 => 100_000,
          25 => 120_000,
          30 => 140_000
        }
      end
    end
  end
end
