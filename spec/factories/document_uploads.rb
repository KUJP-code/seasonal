# frozen_string_literal: true

FactoryBot.define do
  factory :document_upload do
    child_name { 'Lil Tommy' }
    school
    category { :schedule_change }
    document { Rails.public_path.join('apple-touch-icon.png').open }
  end
end
