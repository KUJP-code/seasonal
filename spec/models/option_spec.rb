# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Option do
  subject(:option) { create(:option) }

  let(:event) { create(:event) }

  context 'when valid' do
    it 'saves' do
      valid_option = build(:option)
      valid = valid_option.save!
      expect(valid).to be true
    end

    it 'allows zero-cost options' do
      valid_option = build(:option, cost: 0)
      valid = valid_option.save!
      expect(valid).to be true
    end
  end

  context 'when invalid' do
    it 'without a name' do
      no_name = build(:option, name: nil)
      valid = no_name.save
      expect(valid).to be false
    end

    it 'without a description' do
      no_description = build(:option, description: nil)
      valid = no_description.save
      expect(valid).to be false
    end

    it 'without cost' do
      no_cost = build(:option, cost: nil)
      valid = no_cost.save
      expect(valid).to be false
    end

    it 'with negative cost' do
      neg_cost = build(:option, cost: -1000)
      valid = neg_cost.save
      expect(valid).to be false
    end

    it 'with absurd cost' do
      absurd_cost = build(:option, cost: 50_000)
      valid = absurd_cost.save
      expect(valid).to be false
    end
  end

  context 'with registrations' do
    subject(:op_reg) { create(:child).registrations.create(registerable: option) }

    it 'knows its registrations' do
      option_registrations = option.registrations
      expect(option_registrations).to contain_exactly(op_reg)
    end

    it 'destroys all registrations when destroyed' do
      op_reg
      expect { option.destroy }.to \
        change(Registration, :count)
        .by(-1)
    end

    context 'with children' do
      let(:child) { create(:child) }

      it 'knows its children' do
        child.registrations.create(registerable: option)
        option_children = option.children
        expect(option_children).to include(child)
      end

      it "doesn't destroy registered children when destroyed" do
        child.registrations.create(registerable: option)
        expect { option.destroy }.not_to change(Child, :count)
      end
    end
  end

  context 'with time slot' do
    let(:slot) { create(:time_slot) }

    it "knows the time slot it's an option for" do
      slot_opt = slot.options.create(attributes_for(:option))
      opt_slot = slot_opt.time_slot
      expect(opt_slot).to eq slot
    end

    context 'with event' do
      it "knows the event it's an option for" do
        event.time_slots << slot
        slot_opt = slot.options.create(attributes_for(:option))
        opt_event = slot_opt.event
        expect(opt_event).to eq event
      end
    end

    context 'with school' do
      it "knows the school it's an option for" do
        event_school = event.school
        event.time_slots << slot
        slot_opt = slot.options.create(attributes_for(:option))
        opt_school = slot_opt.school
        expect(opt_school).to eq event_school
      end
    end

    context 'with area' do
      let(:area) { create(:area) }

      it "knows the area it's an option for" do
        # This is an abomination, but better than infinite variables
        area.schools.create(attributes_for(:school)).events.create(attributes_for(:event)).time_slots << slot
        slot_opt = slot.options.create(attributes_for(:option))
        opt_area = slot_opt.area
        expect(opt_area).to eq area
      end
    end
  end
end
