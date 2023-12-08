# frozen_string_literal: true

FactoryBot.define do
  factory :school do
    area
    managers { [build(:school_manager)] }
    name { Faker::Address.city }
  end
end
