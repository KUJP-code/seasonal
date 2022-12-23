# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Child do
  let(:valid_child) { build(:child) }
  let(:child) { create(:child) }

  context 'when valid' do
    it 'saves' do
      valid = valid_child.save!
      expect(valid).to be true
    end

    it 'saves level as unknown by default' do
      lvl = child.level
      expect(lvl).to eq 'unknown'
    end

    it 'can change its level' do
      child.level = 'sky_hi'
      lvl = child.level
      expect(lvl).to eq 'sky_hi'
    end
  end

  context 'when invalid' do
    context 'when birthday invalid' do
      it 'rejects children who are too old' do
        old_child = build(:child, birthday: 20.years.ago)
        valid = old_child.save
        expect(valid).to be false
      end

      it 'rejects children who are too young' do
        young_child = build(:child, birthday: 1.year.ago)
        valid = young_child.save
        expect(valid).to be false
      end
    end
  end
end
