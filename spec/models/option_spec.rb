# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Option do
  subject(:option) { create(:option) }

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
    subject(:op_reg) { option.registrations.create(attributes_for(:registration)) }

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

  context 'with time slots' do
    it '' do
    end

    context 'with events' do
      it '' do
      end
    end

    context 'with schools' do
      it '' do
      end
    end

    context 'with areas' do
      it '' do
      end
    end
  end
end
