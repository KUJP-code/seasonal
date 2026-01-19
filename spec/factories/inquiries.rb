# frozen_string_literal: true

FactoryBot.define do
  factory :inquiry do
    school
    category { 'I' }
    parent_name { Faker::Name.name }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }
  end

  factory :setsumeikai_inquiry, class: 'Inquiry' do
    school
    setsumeikai
    parent_name { '山田太郎' }
    phone { '090-1234-5678' }
    email { 'XkxZs@example.com' }
    child_name { '田中' }
    child_birthday { Date.new(2016, 4, 1) }
    kindy { 'Okurayama' }
    ele_school { '東京都立青山高等学校' }
    start_date { Date.new(2016, 4, 1) }
    requests { 'お疲れ様でした' }
    category { 'R' }
    privacy_policy { 'on' }
  end
end
