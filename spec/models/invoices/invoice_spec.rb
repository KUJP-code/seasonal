# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invoice do
  it 'has a valid factory' do
    expect(build(:invoice)).to be_valid
  end

  it 'automatically updates registrations with new child when child changed' do
    og_child = create(:child)
    invoice = create(
      :invoice,
      child: og_child,
      slot_regs: create_list(:slot_reg, 5, child: og_child),
      opt_regs: create_list(:event_opt_reg, 5, child: og_child)
    )
    new_child = create(:child)
    invoice.update(child: new_child)
    expect(invoice.registrations.map(&:child).uniq.first).to eq(new_child)
  end

  context 'when using calc_cost' do
    let(:event) { create(:event) }
    let(:invoice) { build(:invoice, event:) }

    it 'returns total_cost as an integer' do
      time_slot = create(:time_slot, event:)
      invoice.slot_regs << build(
        :slot_reg,
        registerable_id: time_slot.id,
        registerable_type: 'TimeSlot'
      )
      option = create(:event_option, cost: 10, optionable: event)
      invoice.opt_regs << build(
        :event_opt_reg,
        registerable_id: option.id,
        registerable_type: 'Option'
      )
      expect(invoice.calc_cost).to eq(11)
    end

    it 'calculates cost on save' do
      invoice.slot_regs << build(:slot_reg)
      invoice.opt_regs << build(
        :event_opt_reg,
        registerable: create(:event_option, cost: 10, optionable: event)
      )
      invoice.save
      expect(invoice.total_cost).to eq(11)
    end

    it 'ignores a slot registration whose id is in the array passed as the first parameter' do
      invoice.slot_regs << build(:slot_reg)
      expect(invoice.calc_cost([invoice.slot_regs.first.id])).to eq(0)
    end

    it 'ignores an option registration whose id is in the array passed as the second parameter' do
      invoice.slot_regs << build(:slot_reg)
      invoice.opt_regs << build(:event_opt_reg)
      expect(invoice.calc_cost([], [invoice.opt_regs.first.id])).to eq(1)
    end

    it 'rejects negative costs and returns 0 instead' do
      invoice.adjustments << build(:adjustment, change: -100_000)
      expect(invoice.calc_cost).to eq(0)
    end
  end
end
