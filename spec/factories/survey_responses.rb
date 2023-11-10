FactoryBot.define do
  factory :survey_response do
    answers { "" }
    child { nil }
    survey { nil }
  end
end
