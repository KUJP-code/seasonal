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
  end

  context 'with scopes' do
    # Can't test past scope because of db validations
    it "knows today's time slots" do
      current_slot = create(:time_slot, start_time: 20.minutes.from_now,
                                        end_time: 2.hours.from_now,
                                        event: event)
      todays_slots = event.time_slots.todays_slots
      expect(todays_slots).to contain_exactly(current_slot)
    end

    it 'knows future time slots' do
      future_slot = create(:time_slot, start_time: 1.day.from_now, end_time: 2.days.from_now, event: event)
      future_slots = event.time_slots.future_slots
      expect(future_slots).to contain_exactly(future_slot)
    end

    it 'knows morning slots' do
      time_slot.update(morning: true)
      morning_slots = described_class.all.morning
      expect(morning_slots).to contain_exactly time_slot
    end

    it 'knows afternoon slots' do
      time_slot.update(morning: false)
      afternoon_slots = described_class.all.afternoon
      expect(afternoon_slots).to contain_exactly time_slot
    end
  end

  context 'with morning' do
    let(:morning) { create(:time_slot, morning: true) }

    before do
      time_slot.update(morning_slot_id: morning.id)
    end

    it 'knows its morning' do
      morning_slot = time_slot.morning_slot
      expect(morning_slot).to eq morning
    end

    it 'morning knows it' do
      morning_afternoon = morning.afternoon_slot
      expect(morning_afternoon).to eq time_slot
    end
  end

  context 'with event' do
    it 'knows its event' do
      associated_ts = event.time_slots.create(attributes_for(:time_slot))
      ts_event = associated_ts.event
      expect(ts_event).to eq event
    end
  end

  context 'with registrations' do
    let(:child) { create(:child) }
    let(:registration) { time_slot.registrations.create(child: child, invoice: create(:invoice)) }

    it 'knows its registrations' do
      slot_registrations = time_slot.registrations
      expect(slot_registrations).to contain_exactly(registration)
    end

    it 'destroys its registrations when destroyed' do
      registration
      expect { time_slot.destroy }.to \
        change(Registration, :count)
        .by(-1)
    end

    context 'with children' do
      it 'knows which children are attending' do
        registration
        slot_children = time_slot.children
        expect(slot_children).to contain_exactly(child)
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

  context 'with options' do
    subject(:option) { time_slot.options.create(attributes_for(:option)) }

    it 'knows its available options' do
      slot_options = time_slot.options
      expect(slot_options).to contain_exactly(option)
    end

    it 'destroys its options when destroyed' do
      option
      expect { time_slot.destroy }.to \
        change(Option, :count)
        .by(-1)
    end

    context 'with registered options' do
      let(:option_registration) { option.registrations.create(child: create(:child), invoice: create(:invoice)) }

      it 'knows its registered options' do
        option_registrations = time_slot.option_registrations
        expect(option_registrations).to contain_exactly(option_registration)
      end
    end
  end
end
