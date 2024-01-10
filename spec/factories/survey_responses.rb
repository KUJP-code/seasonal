# frozen_string_literal: true

FactoryBot.define do
  factory :survey_response do
    child
    survey
    answers { { test: 'test' } }
  end
end
