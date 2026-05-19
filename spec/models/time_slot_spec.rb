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

  describe 'attachment setters' do
    it 'ignores blank image ids' do
      slot = create(:time_slot)
      slot.image.attach(
        io: StringIO.new('image data'),
        filename: 'slot.png',
        content_type: 'image/png'
      )

      original_blob = slot.image.blob

      slot.update!(image_id: '')

      expect(slot.reload.image.blob).to eq(original_blob)
    end

    it 'ignores blank avif ids' do
      slot = create(:time_slot)
      slot.avif.attach(
        io: StringIO.new('avif data'),
        filename: 'slot.avif',
        content_type: 'image/avif'
      )

      original_blob = slot.avif.blob

      slot.update!(avif_id: '')

      expect(slot.reload.avif.blob).to eq(original_blob)
    end
  end

  describe 'pricing rule defaults' do
    it 'keeps legacy snack and elementary extension prices before May 2026' do
      event = create(:event,
                     start_date: Date.new(2026, 4, 30),
                     end_date: Date.new(2026, 4, 30))
      slot = create(:time_slot, :morning, event:)
      afternoon = slot.afternoon_slot

      expect(TimeSlot.snack_cost_for(event)).to eq(200)
      expect(afternoon.options.departure.pluck(:cost)).to eq([550, 1_100, 1_650, 2_200])
      expect(slot.options.arrival.pluck(:cost)).to eq([550, 1_100, 1_650])
    end

    it 'uses new snack and elementary extension prices from May 2026' do
      event = create(:event,
                     start_date: Date.new(2026, 5, 1),
                     end_date: Date.new(2026, 5, 1))
      slot = create(:time_slot, :morning, event:)
      afternoon = slot.afternoon_slot

      expect(TimeSlot.snack_cost_for(event)).to eq(225)
      expect(afternoon.options.departure.pluck(:cost)).to eq([660, 1_320, 1_980, 2_640])
      expect(slot.options.arrival.pluck(:cost)).to eq([660, 1_320, 1_980])
    end

    it 'uses kindy pricing for elementary middle extension from May 2026' do
      event = create(:event,
                     start_date: Date.new(2026, 5, 1),
                     end_date: Date.new(2026, 5, 1))
      slot = create(:time_slot, :morning, category: :special, event:)

      expect(slot.options.extension.first.cost).to eq(1_980)
      expect(slot.options.k_extension.first.cost).to eq(1_980)
    end
  end
end
