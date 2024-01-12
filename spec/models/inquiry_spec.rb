# frozen_string_literal: true

require 'rails_helper'

describe Inquiry do
  include ActiveSupport::Testing::TimeHelpers

  it 'has a valid factory' do
    expect(build(:inquiry)).to be_valid
  end

  context 'when calculating school grade (for 2023 school year)' do
    before do
      travel_to Date.new(2023, 1, 1)
    end

    it 'is 1st grade when birthday is 01/04/2016' do
      inquiry = build(:inquiry, child_birthday: Date.new(2016, 4, 1))
      expect(inquiry.child_grade).to eq('小学１年生')
    end

    it 'is 2nd grade when birthday is 31/03/2016' do
      inquiry = build(:inquiry, child_birthday: Date.new(2016, 3, 31))
      expect(inquiry.child_grade).to eq('小学２年生')
    end

    it 'is 2nd grade middle school when birthday is 01/04/2009' do
      inquiry = build(:inquiry, child_birthday: Date.new(2009, 4, 1))
      expect(inquiry.child_grade).to eq('中学２年生')
    end

    it 'is 3rd grade middle school when birthday is 31/03/2009' do
      inquiry = build(:inquiry, child_birthday: Date.new(2009, 3, 31))
      expect(inquiry.child_grade).to eq('中学３年生')
    end
  end
end
