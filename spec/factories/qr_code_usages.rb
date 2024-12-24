# frozen_string_literal:true

FactoryBot.define do
  factory :qr_code_usage do
    association :qr_code
    ip_address { '127.0.0.1' }
    user_agent { 'RSpec Test Agent' }
  end
end
