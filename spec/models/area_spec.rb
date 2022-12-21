# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Area do
  let(:valid_area) { build(:area) }
  let(:area) { create(:area) }

  context 'when valid' do
    it 'saves' do
      valid = valid_area.save
      expect(valid).to be true
    end
  end

  context 'when invalid' do
    it "doesn't save without a name" do
      valid_area.name = nil
      valid = valid_area.save
      expect(valid).to be false
    end

    it "doesn't save without a manager" do
      valid_area.manager = nil
      valid = valid_area.save
      expect(valid).to be false
    end
  end

  context 'with associations' do
    context 'with manager' do
      it 'knows its manager' do
        am = create(:am_user)
        area = create(:area, manager: am)
        manager = area.manager
        expect(manager).to be am
      end
    end
  end
end
