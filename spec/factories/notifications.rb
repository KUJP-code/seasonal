# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    link { '/user/1' }
    message { 'This is a test notification' }
    user
  end
end
