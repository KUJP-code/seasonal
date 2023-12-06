# frozen_string_literal: true

FactoryBot.define do
  factory :management do
    factory :area_management do
      manageable factory: :area
    end

    factory :school_management do
      manageable factory: :school
    end
  end
end
