# frozen_string_literal: true

FactoryBot.define do
  factory :rashimba_inquiry do
    kind { 'sponsor' }
    email { 'inquirer@example.com' }
    company { 'Example Company' }
    name { 'Inquiry Person' }
    privacy_consent { true }
    consented_at { Time.current }
    ip_address { '192.0.2.1' }
    submission_key { SecureRandom.uuid }
    submission_digest { Digest::SHA256.hexdigest(submission_key) }

    trait :release_notification do
      kind { 'release_notification' }
      company { nil }
      name { nil }
      child_age { '3-5' }
    end
  end
end
