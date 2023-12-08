# frozen_string_literal: true

FactoryBot.define do
  factory :setsumeikai do
    school
    setsumeikai_involvements { [build(:setsumeikai_involvement, school: school)] }
    start { 1.day.from_now }
    attendance_limit { 5 }
    release_date { 1.day.ago }
  end
end
