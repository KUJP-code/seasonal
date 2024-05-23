# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TimeSlot do
  subject(:time_slot) { build(:time_slot) }

  it 'has a valid factory' do
    expect(create(:time_slot)).to be_valid
  end

  context 'when calling closed?' do
    it 'returns true if closed' do
      time_slot.closed = true
      expect(time_slot.closed?).to be true
    end

    it 'returns true if after the time in close_at' do
      time_slot.close_at = 1.minute.ago
      time_slot.closed = false
      expect(time_slot.closed?).to be true
    end

    it 'sets the closed DB column to true if after close_at' do
      time_slot = create(:time_slot, close_at: 1.minute.ago, closed: false)
      expect { time_slot.closed? }.to change { time_slot.closed }
        .from(false).to(true)
    end

    it 'returns false if not closed and prior to close_at' do
      time_slot.close_at = 1.hour.from_now
      expect(time_slot.closed?).to be false
    end

    it 'does not modify the DB column if not closed and prior to close_at' do
      time_slot = create(:time_slot, close_at: 1.hour.from_now, closed: false)
      expect { time_slot.closed? }.not_to change(time_slot, :closed)
    end
  end
end
