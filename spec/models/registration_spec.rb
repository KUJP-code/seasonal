# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Registration do
  let(:child) { create(:child) }
  let(:time_slot) { create(:time_slot, cost: 8000) }
  let(:option) { create(:option, time_slot: time_slot, cost: 4000) }
  let(:registration) { child.registrations.create(registerable: time_slot) }

  context 'when valid' do
    it 'saves when registering for time slot' do
      slot_registration = child.registrations.build(registerable: time_slot)
      valid = slot_registration.save!
      expect(valid).to be true
    end

    it 'saves when registering for option' do
      opt_registration = child.registrations.build(registerable: option)
      valid = opt_registration.save!
      expect(valid).to be true
    end
  end

  context 'with child' do
    it 'knows its child' do
      child_registration = create(:registration, child: child, registerable: time_slot)
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

  context 'with option' do
    it 'knows its option' do
      registration.registerable = option
      registration_option = registration.registerable
      expect(registration_option).to eq option
    end

    context 'with time slot' do
      it 'knows the time slot the option applies to' do
        registration.registerable = option
        option_slot = registration.registerable.time_slot
        expect(option_slot).to eq time_slot
      end
    end

    context 'with event' do
      it 'knows the event the option applies to' do
        registration.registerable = option
        slot_event = time_slot.event
        option_event = registration.registerable.event
        expect(option_event).to eq slot_event
      end
    end
  end

  context 'with scopes' do
    before do
      child.registrations.create(registerable: time_slot)
      child.registrations.create(registerable: option)
    end

    it 'knows which registrations are for time slots' do
      slot_registrations = described_class.all.slot_registrations
      reg_returned = slot_registrations.length
      expect(reg_returned).to be 1
    end

    it 'knows which registrations are for options' do
      option_registrations = described_class.all.option_registrations
      reg_returned = option_registrations.length
      expect(reg_returned).to be 1
    end
  end

  context 'with adjustments' do
    it 'time slot can have its cost decreased' do
      slot_reg = time_slot.registrations.create!(attributes_for(:registration, child: child, cost: 8000))
      slot_reg.adjustments.create(change: -2000, reason: 'testtesttest')
      slot_cost = slot_reg.cost
      adjusted_cost = slot_reg.adjusted_cost
      expect(adjusted_cost).to be < slot_cost
    end

    it 'option can have its cost decreased' do
      opt_reg = option.registrations.create!(attributes_for(:registration, child: child, cost: 4000))
      opt_reg.adjustments.create(change: -2000, reason: 'testtesttest')
      opt_cost = opt_reg.cost
      adjusted_cost = opt_reg.adjusted_cost
      expect(adjusted_cost).to be < opt_cost
    end
  end
end
