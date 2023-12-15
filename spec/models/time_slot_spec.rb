# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TimeSlot do
  include ActiveSupport::Testing::TimeHelpers

  subject(:time_slot) { build(:time_slot) }

  it 'has a valid factory' do
    expect(create(:time_slot)).to be_valid
  end

  context 'when testing winter 2023 close dates' do
    it 'does not close Monster Party before 2pm Tue 19th Dec' do
      time_slot.name = 'モンスターパペット'
      travel_to Time.zone.local(2023, 12, 19, 10, 0, 0)
      expect(time_slot.closed?).to be false
    end

    it 'closes Monster Party after 2pm Tue 19th Dec' do
      time_slot.name = 'モンスターパペット'
      travel_to Time.zone.local(2023, 12, 19, 18, 0, 0)
      expect(time_slot.closed?).to be true
    end

    it 'does not close 雪だるまランプ before 2pm Thu 28th Dec' do
      time_slot.name = '雪だるまランプ'
      travel_to Time.zone.local(2023, 12, 28, 10, 0, 0)
      expect(time_slot.closed?).to be false
    end

    it 'closes 雪だるまランプ after 2pm Thu 28th Dec' do
      time_slot.name = '雪だるまランプ'
      travel_to Time.zone.local(2023, 12, 28, 18, 0, 0)
      expect(time_slot.closed?).to be true
    end

    it 'does not close スパイゲーム！・ウィンタースライム before 2pm Fri 5th Jan 2024' do
      time_slot.name = 'スパイゲーム！・ウィンタースライム'
      travel_to Time.zone.local(2024, 1, 5, 10, 0, 0)
      expect(time_slot.closed?).to be false
    end

    it 'closes スパイゲーム！・ウィンタースライム after 2pm Fri 5th Jan 2024' do
      time_slot.name = 'スパイゲーム！・ウィンタースライム'
      travel_to Time.zone.local(2024, 1, 5, 18, 0, 0)
      expect(time_slot.closed?).to be true
    end
  end

  context 'when calling #closed?' do
    it 'returns true if closed' do
      time_slot.closed = true
      expect(time_slot.closed?).to be true
    end

    it 'returns true if after 2pm on the close date' do
      time_slot.name = 'モンスターパペット'
      time_slot.closed = false
      travel_to Time.zone.local(2023, 12, 19, 18, 0, 0)
      expect(time_slot.closed?).to be true
    end

    it 'sets the closed DB column to true if after close date' do
      time_slot = create(:time_slot, name: 'モンスターパペット', closed: false)
      travel_to Time.zone.local(2023, 12, 19, 18, 0, 0)
      expect { time_slot.closed? }.to change { time_slot.closed }
        .from(false).to(true)
    end

    it 'returns false if not closed and prior to close date' do
      time_slot.name = 'モンスターパペット'
      travel_to Time.zone.local(2023, 12, 19, 10, 0, 0)
      expect(time_slot.closed?).to be false
    end

    it 'does not modify the DB column if not closed and prior to close date' do
      time_slot = create(:time_slot, name: 'モンスターパペット', closed: false)
      travel_to Time.zone.local(2023, 12, 19, 10, 0, 0)
      expect { time_slot.closed? }.not_to change(time_slot, :closed)
    end
  end
end
