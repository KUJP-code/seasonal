# frozen_string_literal: true

FactoryBot.define do
  factory :management do
    trait :area do
      manager { create(:am_user) }
      manageable { create(:area) }
    end

    trait :school do
      manager { create(:sm_user) }
      manageable { create(:school) }
    end

    factory :area_management, traits: [:area]
    factory :school_management, traits: [:school]
  end
end
