# frozen_string_literal: true

FactoryBot.define do
  factory :invoice do
    total_cost { 10_000 }
    billing_date { nil }
    parent { create(:customer_user) }
    event { create(:event) }
  end
end
