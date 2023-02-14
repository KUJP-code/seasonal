# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Adjustment do
  context 'when valid' do
    it 'saves' do
      adjustment = build(:adjustment)
      valid = adjustment.save!
      expect(valid).to be true
    end
  end
end
