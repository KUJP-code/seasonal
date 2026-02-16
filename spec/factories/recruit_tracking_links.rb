# frozen_string_literal: true

FactoryBot.define do
  factory :recruit_tracking_link do
    sequence(:name) { |n| "Tracking Link #{n}" }
    sequence(:slug) { |n| "tracking-link-#{n}" }
    active { true }
  end
end
