# frozen_string_literal: true

FactoryBot.define do
  factory :document_upload do
    child_name { 'Lil Tommy' }
    school
    category { :schedule_change }
    document { Rails.root.join('app/assets/images/sm_login_splash.png').open }
  end
end
