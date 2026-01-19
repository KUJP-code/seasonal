# frozen_string_literal: true

require 'rails_helper'

describe Inquiry do
  include ActiveSupport::Testing::TimeHelpers

  it 'has a valid factory' do
    expect(build(:inquiry)).to be_valid
  end

  it 'has a valid setsumeikai inquiry factory' do
    expect(build(:setsumeikai_inquiry)).to be_valid
  end

  context 'when calculating school grade during 2023 school year' do
    before do
      travel_to Date.new(2024, 3, 14)
    end

    it 'gives real age when 1 year old' do
      inquiry = build(:inquiry, child_birthday: Date.new(2022, 4, 11))
      expect(inquiry.child_grade).to eq('1歳')
    end

    it 'gives real age when 2 years old' do
      inquiry = build(:inquiry, child_birthday: Date.new(2021, 4, 11))
      expect(inquiry.child_grade).to eq('2歳')
    end

    it 'is 3 years old when born 4/10/2020' do
      inquiry = build(:inquiry, child_birthday: Date.new(2020, 10, 4))
      expect(inquiry.child_grade).to eq('3歳')
    end

    it 'is start of kindy when born before school start' do
      inquiry = build(:inquiry, child_birthday: Date.new(2020, 4, 1))
      expect(inquiry.child_grade).to eq('年少')
    end

    it 'is 1st grade when born after school start' do
      inquiry = build(:inquiry, child_birthday: Date.new(2016, 4, 2))
      expect(inquiry.child_grade).to eq('小学１年生')
    end

    it 'is 2nd grade when born before school start' do
      inquiry = build(:inquiry, child_birthday: Date.new(2016, 4, 1))
      expect(inquiry.child_grade).to eq('小学２年生')
    end
  end

  context 'when calculating school grade during 2024 school year' do
    before do
      travel_to Date.new(2024, 4, 2)
    end

    it 'is start of kindy when born 4/10/2020' do
      inquiry = build(:inquiry, child_birthday: Date.new(2020, 10, 4))
      expect(inquiry.child_grade).to eq('年少')
    end

    it 'is 2nd grade when born before school start' do
      inquiry = build(:inquiry, child_birthday: Date.new(2016, 4, 2))
      expect(inquiry.child_grade).to eq('小学２年生')
    end

    it 'is 3rd grade when born after school start' do
      inquiry = build(:inquiry, child_birthday: Date.new(2016, 4, 1))
      expect(inquiry.child_grade).to eq('小学３年生')
    end
  end

  context 'when calculating school grade during 2025 school year' do
    before do
      travel_to Date.new(2025, 4, 2)
    end

    it 'is middle of kindy when born 4/10/2020' do
      inquiry = build(:inquiry, child_birthday: Date.new(2020, 10, 4))
      expect(inquiry.child_grade).to eq('年中')
    end

    it 'is 3rd grade when born after school start' do
      inquiry = build(:inquiry, child_birthday: Date.new(2016, 4, 2))
      expect(inquiry.child_grade).to eq('小学３年生')
    end

    it 'is 4th grade when born before school start' do
      inquiry = build(:inquiry, child_birthday: Date.new(2016, 4, 1))
      expect(inquiry.child_grade).to eq('小学４年生')
    end
  end

  describe 'setsumeikai cutoff validation' do
    it 'rejects R inquiries after close_at (cutoff)' do
      school = create(:school)
      setsumeikai = create(
        :setsumeikai,
        school:,
        start: 1.day.from_now,
        release_date: 2.days.ago,
        close_at: 1.day.ago # already past cutoff
      )

      inquiry = build(:inquiry,
                      category: 'R',
                      school:,
                      setsumeikai:,
                      privacy_policy: 'on')

      expect(inquiry).not_to be_valid
      expect(inquiry.errors[:setsumeikai_id]).to include('申し込みは締め切られました。')
    end
  end
end
