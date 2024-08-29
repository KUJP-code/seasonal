# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event do
  context 'when using factory for tests' do
    it 'has a valid factory' do
      expect(build(:event)).to be_valid
    end

    it 'has member prices by default' do
      expect(create(:event).member_prices).to be_present
    end

    it 'has non-member prices by default' do
      expect(create(:event).non_member_prices).to be_present
    end
  end

  it 'rejects goals that will not fit in the column' do
    # This is 1 more than the max value of a 4 bit signed int
    event = build(:event, goal: 2_147_483_648)
    expect(event).not_to be_valid
  end
end
