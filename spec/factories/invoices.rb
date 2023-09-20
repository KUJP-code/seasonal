# frozen_string_literal: true

FactoryBot.define do
  factory :invoice do
    total_cost { 10_000 }
    child { create(:child) }
    event { create(:event) }
  end
end
