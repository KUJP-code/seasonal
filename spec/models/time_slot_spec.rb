# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TimeSlot do
  let(:time_slot) { create(:time_slot) }
  let(:event) { create(:event) }

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

  context 'with scopes' do
    # Can't test past scope because of db validations
    it "knows today's time slots" do
      current_slot = create(:time_slot, start_time: 1.hour.from_now, end_time: 2.hours.from_now, event: event)
      todays_slots = event.time_slots.todays_slots
      expect(todays_slots).to include(current_slot)
    end

    it 'knows future time slots' do
      future_slot = create(:time_slot, start_time: 1.day.from_now, end_time: 2.days.from_now, event: event)
      todays_slots = event.time_slots.future_slots
      expect(todays_slots).to include(future_slot)
    end
  end

  context 'with event' do
    it 'knows its event' do
      associated_ts = event.time_slots.create(attributes_for(:time_slot))
      ts_event = associated_ts.event
      expect(ts_event).to eq event
    end
  end

  context 'with children' do
    xit 'knows which children are attending' do
    end

    xit "knows which children at its school aren't attending" do
    end

    context 'with user' do
      xit 'knows which users have registered children' do
      end

      xit "knows which users haven't registered children" do
      end
    end
  end

  context 'with school' do
    let(:school) { create(:school) }

    it 'knows which school its held at' do
      event.school = school
      school_slot = event.time_slots.create(attributes_for(:time_slot))
      slot_school = school_slot.school
      expect(slot_school).to eq school
    end
  end
end
