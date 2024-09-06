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

    it 'returns a hash with a total_cost key' do
      expect(invoice.calc_cost).to have_key(:total_cost)
    end

    it 'calculates cost on save' do
      slot = create(:time_slot)
      invoice.slot_regs << build(:slot_reg, registerable: slot)
      invoice.opt_regs <<
        build(:event_opt_reg, registerable: create(:event_option, cost: 10))
      invoice.save
      expect(invoice.total_cost).to eq(11)
    end

    it 'ignores a time slot reg marked for destruction' do
      ignored_slot = create(:time_slot)
      ignored_reg = build(:slot_reg, registerable: ignored_slot)
      ignored_reg.mark_for_destruction
      invoice.slot_regs << ignored_reg
      expect(invoice.calc_cost[:total_cost]).to eq(0)
    end

    it 'ignores an option reg marked for destruction' do
      ignored_opt = create(:event_option, cost: 10)
      invoice.slot_regs << build(:slot_reg, registerable: create(:time_slot))
      ignored_reg = build(:event_opt_reg, registerable: ignored_opt)
      ignored_reg.mark_for_destruction
      invoice.opt_regs << ignored_reg
      expect(invoice.calc_cost[:total_cost]).to eq(1)
    end

    it 'rejects negative costs and returns 0 instead' do
      invoice.adjustments << build(:adjustment, change: -100_000)
      expect(invoice.calc_cost[:total_cost]).to eq(0)
    end
  end
end
