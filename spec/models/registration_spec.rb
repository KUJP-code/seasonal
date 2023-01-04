# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Registration do
  let(:child) { create(:child) }
  let(:time_slot) { create(:time_slot) }
  let(:registration) { child.registrations.create(registerable: time_slot) }

  context 'when valid' do
    let(:valid_registration) { build(:registration) }

    it 'saves' do
      valid = valid_registration.save!
      expect(valid).to be true
    end
  end

  context 'with child' do
    it 'knows its child' do
      child_registration = create(:registration, child: child)
      registration_child = child_registration.child
      expect(registration_child).to eq child
    end

    context 'with parent' do
      it 'knows its childs parent' do
        child_parent = child.parent
        registration_parent = registration.parent
        expect(child_parent).to eq registration_parent
      end
    end
  end

  context 'with time slot' do
    it 'knows its time slot' do
      registration_slot = registration.registerable
      expect(registration_slot).to eq time_slot
    end

    context 'with event' do
      it 'knows its event' do
        registration_event = registration.event
        slot_event = time_slot.event
        expect(registration_event).to eq slot_event
      end
    end

    context 'with school' do
      it 'knows its school' do
        registration_school = registration.school
        slot_school = time_slot.school
        expect(registration_school).to eq slot_school
      end
    end

    context 'with area' do
      it 'knows its area' do
        registration_area = registration.area
        slot_area = time_slot.area
        expect(registration_area).to eq slot_area
      end
    end
  end
end
