# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Adjustment do
  let(:child) { create(:child) }
  let(:time_slot) { create(:time_slot) }
  let(:slot_registration) { time_slot.registrations.create(child: child, cost: 8000) }
  let(:valid_adjustment) { slot_registration.adjustments.build(attributes_for(:adjustment)) }

  context 'when valid' do
    it 'saves' do
      valid = valid_adjustment.save!
      expect(valid).to be true
    end

    context 'when invalid' do
      it 'no change in cost' do
        valid_adjustment.change = 0
        valid = valid_adjustment.save
        expect(valid).to be false
      end

      it 'change is positive' do
        valid_adjustment.change = 4000
        valid = valid_adjustment.save
        expect(valid).to be false
      end

      it 'magnitude of change is greater than registration cost' do
        valid_adjustment.change = -10_000
        valid = valid_adjustment.save
        expect(valid).to be false
      end

      it 'no reason given' do
        valid_adjustment.reason = nil
        valid = valid_adjustment.save
        expect(valid).to be false
      end
    end

    context 'with option registration' do
      let(:option) { create(:option) }

      it 'saves' do
        option_registration = create(:option, time_slot: time_slot).registrations.create(child: child, cost: 4000)
        valid_adjustment = option_registration.adjustments.build(attributes_for(:adjustment))
        valid = valid_adjustment.save!
        expect(valid).to be true
      end
    end

    with_versioning do
      it 'creates a paper trail on create' do
        valid_adjustment.save!
        expect(valid_adjustment).to be_versioned
      end

      it 'creates a paper trail on update' do
        valid_adjustment.save!
        valid_adjustment.update(change: -500)
        expect(valid_adjustment).to be_versioned
      end

      it 'creates a paper trail on destroy' do
        valid_adjustment.save!
        valid_adjustment.destroy
        expect(valid_adjustment).to be_versioned
      end

      it 'can be restored to previous version' do
        valid_adjustment.save!
        valid_adjustment.update(change: -500)
        valid_adjustment.paper_trail.previous_version.save
        reverted_cost = valid_adjustment.reload.change
        expect(reverted_cost).to eq(-2000)
      end

      it 'can be restored after destruction' do
        valid_adjustment.save!
        valid_adjustment.destroy
        restored_version = valid_adjustment.versions.last.reify
        restored = restored_version.save!
        expect(restored).to be true
      end
    end
  end
end
