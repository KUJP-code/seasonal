# frozen_string_literal: true

FactoryBot.define do
  factory :setsumeikai do
    school
    setsumeikai_involvements { [build(:setsumeikai_involvement, school: school)] }
    start { 2.days.from_now }
    attendance_limit { 5 }
    release_date { 1.day.ago }
    close_at { 1.day.from_now }
  end
end
