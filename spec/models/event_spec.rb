# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event do
  context 'when using factory for tests' do
    it 'has a valid factory' do
      expect(create(:event)).to be_valid
    end

    it 'has member prices by default' do
      expect(create(:event).member_prices).to be_present
    end

    it 'has non-member prices by default' do
      expect(create(:event).non_member_prices).to be_present
    end
  end
end
