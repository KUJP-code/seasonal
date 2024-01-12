# frozen_string_literal: true

require 'rails_helper'

describe Inquiry do
  include ActiveSupport::Testing::TimeHelpers

  it 'has a valid factory' do
    expect(build(:inquiry)).to be_valid
  end

  context 'when calculating school grade during 2023 school year' do
    before do
      travel_to Date.new(2024, 1, 12)
    end

    it 'is 1st grade when birthday is 02/04/2016' do
      inquiry = build(:inquiry, child_birthday: Date.new(2016, 4, 2))
      expect(inquiry.child_grade).to eq('小学１年生')
    end

    it 'is 2nd grade when birthday is 01/04/2016' do
      inquiry = build(:inquiry, child_birthday: Date.new(2016, 4, 1))
      expect(inquiry.child_grade).to eq('小学２年生')
    end
  end

  context 'when calculating school grade during 2024 school year' do
    before do
      travel_to Date.new(2024, 4, 2)
    end

    it 'is 2nd grade when birthday is 02/04/2016' do
      inquiry = build(:inquiry, child_birthday: Date.new(2016, 4, 2))
      expect(inquiry.child_grade).to eq('小学２年生')
    end

    it 'is 3rd grade when birthday is 01/04/2016' do
      inquiry = build(:inquiry, child_birthday: Date.new(2016, 4, 1))
      expect(inquiry.child_grade).to eq('小学３年生')
    end
  end

  context 'when calculating school grade during 2025 school year' do
    before do
      travel_to Date.new(2025, 4, 2)
    end

    it 'is 3rd grade when birthday is 02/04/2016' do
      inquiry = build(:inquiry, child_birthday: Date.new(2016, 4, 2))
      expect(inquiry.child_grade).to eq('小学３年生')
    end

    it 'is 4th grade when birthday is 01/04/2016' do
      inquiry = build(:inquiry, child_birthday: Date.new(2016, 4, 1))
      expect(inquiry.child_grade).to eq('小学４年生')
    end
  end
end
