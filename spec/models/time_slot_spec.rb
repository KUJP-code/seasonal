# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TimeSlot do
  let(:time_slot) { create(:time_slot) }

  context 'when valid' do
    let(:valid_time_slot) { build(:time_slot) }

    it 'saves' do
      valid = valid_time_slot.save!
      expect(valid).to be true
    end

    it 'allows zero-cost time slots' do
      valid_time_slot.cost = 0
      valid = valid_time_slot.save!
      expect(valid).to be true
    end
  end

  context 'when invalid' do
    it 'without name' do
      no_name = build(:time_slot, name: nil)
      valid = no_name.save
      expect(valid).to be false
    end

    it 'without start time' do
      no_start = build(:time_slot, start_time: nil)
      valid = no_start.save
      expect(valid).to be false
    end

    it 'with start time before current time' do
      past_start = build(:time_slot, start_time: 1.day.ago)
      valid = past_start.save
      expect(valid).to be false
    end

    it 'without end time' do
      no_end = build(:time_slot, end_time: nil)
      valid = no_end.save
      expect(valid).to be false
    end

    it 'with end time before current time' do
      past_end = build(:time_slot, end_time: 1.day.ago)
      valid = past_end.save
      expect(valid).to be false
    end

    it 'with end time before start time' do
      end_before = build(:time_slot, start_time: 3.days.from_now, end_time: 1.day.from_now)
      valid = end_before.save
      expect(valid).to be false
    end

    it 'without description' do
      no_description = build(:time_slot, description: nil)
      valid = no_description.save
      expect(valid).to be false
    end

    it 'with short description' do
      short_description = build(:time_slot, description: '123456789')
      valid = short_description.save
      expect(valid).to be false
    end

    it 'without cost' do
      no_cost = build(:time_slot, cost: nil)
      valid = no_cost.save
      expect(valid).to be false
    end

    it 'with negative cost' do
      neg_cost = build(:time_slot, cost: -1000)
      valid = neg_cost.save
      expect(valid).to be false
    end

    it 'with absurd cost' do
      absurd_cost = build(:time_slot, cost: 50_000)
      valid = absurd_cost.save
      expect(valid).to be false
    end
  end
end
