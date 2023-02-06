# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event do
  let(:event) { create(:event) }

  context 'when valid' do
    let(:valid_event) { build(:event) }

    it 'saves' do
      valid = valid_event.save!
      expect(valid).to be true
    end

    # Can't test past events cos of db constraints
    it 'lists current events' do
      current_event = create(:event, start_date: Time.zone.today, end_date: Time.zone.today)
      current_events = described_class.all.current_events
      expect(current_events).to match_array(current_event)
    end

    it 'lists future events' do
      future_event = create(:event, start_date: 2.days.from_now)
      future_events = described_class.all.future_events
      expect(future_events).to match_array(future_event)
    end
  end

  context 'when invalid' do
    it "doesn't save without a name" do
      no_name = build(:event, name: nil)
      valid = no_name.save
      expect(valid).to be false
    end

    it "doesn't save without a description" do
      no_description = build(:event, description: nil)
      valid = no_description.save
      expect(valid).to be false
    end

    it "doesn't save without a start date" do
      no_start_date = build(:event, start_date: nil)
      valid = no_start_date.save
      expect(valid).to be false
    end

    it "doesn't save when start date before current date" do
      past_start = build(:event, start_date: 7.days.ago)
      valid = past_start.save
      expect(valid).to be false
    end

    it "doesn't save without end date" do
      no_end_date = build(:event, end_date: nil)
      valid = no_end_date.save
      expect(valid).to be false
    end

    it "doesn't save when end date before current date" do
      past_end = build(:event, end_date: 7.days.ago)
      valid = past_end.save
      expect(valid).to be false
    end

    it "doesn't save when start date before end date" do
      past_start = build(:event, start_date: 3.days.from_now, end_date: 2.days.from_now)
      valid = past_start.save
      expect(valid).to be false
    end

    it "doesn't save without school" do
      no_school = build(:event, school: nil)
      valid = no_school.save
      expect(valid).to be false
    end
  end

  context 'with area' do
    subject(:associated_event) { create(:event, school: school) }

    let(:area) { create(:area) }
    let(:school) { create(:school, area: area) }

    it 'knows its area' do
      event_area = associated_event.area
      expect(event_area).to eq area
    end
  end

  context 'with school' do
    subject(:associated_event) { create(:event, school: school) }

    let(:school) { create(:school) }

    it 'knows its school' do
      event_school = associated_event.school
      expect(event_school).to eq school
    end
  end

  context 'with time slots' do
    let(:slot) { event.time_slots.create(attributes_for(:time_slot)) }

    it 'knows its time slots' do
      event_slots = event.time_slots
      expect(event_slots).to contain_exactly(slot)
    end

    context 'with registrations' do
      it 'knows its time slot registrations' do
        registration = slot.registrations.create(child: create(:child))
        event_registrations = event.registrations
        expect(event_registrations).to contain_exactly(registration)
      end

      it 'knows its option registrations' do
        option = slot.options.create(attributes_for(:option))
        event_opt_reg = option.registrations.create(child: create(:child))
        event_opt_registrations = event.option_registrations
        expect(event_opt_registrations).to contain_exactly(event_opt_reg)
      end
    end

    context 'with children through registrations' do
      it 'knows which children are attending' do
        child = create(:child, school: event.school)
        child.registrations.create(registerable: slot)
        event_children = event.children
        expect(event_children).to include(child)
      end

      it 'knows which attending children are from other schools' do
        diff_school_child = create(:child)
        diff_school_child.registrations.create(registerable: slot)
        foreign_kids = event.diff_school_children
        expect(foreign_kids).to contain_exactly(diff_school_child)
      end
    end

    context 'with options through time slots' do
      it 'knows its available options' do
        option = slot.options.create(attributes_for(:option))
        event_options = event.slot_options
        expect(event_options).to contain_exactly(option)
      end
    end
  end
end
