# frozen_string_literal: true

FactoryBot.define do
  factory :invoice do
    child factory: :internal_child
    event
  end
end
