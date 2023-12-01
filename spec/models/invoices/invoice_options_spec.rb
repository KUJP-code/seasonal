# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invoice do
  let(:event) { create(:event) }
  let(:invoice) { build(:invoice, event: event) }

  context 'when calculating cost for slot options' do
    let(:slot_option) { create(:slot_option, cost: 10) }

    it 'calculates cost with option on time slot' do
      invoice.slot_regs << build(:slot_reg, registerable: slot_option.optionable)
      invoice.opt_regs << build(:opt_reg, registerable: slot_option)
      invoice.calc_cost
      expect(invoice.total_cost).to eq(11)
    end

    it 'does not calculate cost for options without time slot' do
      invoice.opt_regs << build(:opt_reg, registerable: slot_option)
      invoice.calc_cost
      expect(invoice.total_cost).to eq(0)
    end

    it 'destroys orphan options' do
      child = create(:child)
      invoice.slot_regs << build(:slot_reg, registerable: slot_option.optionable, child: child)
      invoice.opt_regs << build(:opt_reg, registerable: slot_option, child: child)
      invoice.calc_cost && invoice.save
      invoice.update(slot_regs: [])
      expect(invoice.reload.opt_regs.count).to eq(0)
    end
  end

  context 'when calculating cost for event options' do
    it 'calculates cost for event options' do

    end

    it 'does not allow registering for an event option sibling is registered for' do

    end
  end
end
