# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invoice do
  let(:event) { create(:event) }
  let(:invoice) { build(:invoice, event: event) }

  context 'when calculating cost for slot options' do
    let(:slot_option) { create(:slot_option, cost: 10) }

    it 'calculates cost with option on time slot' do
      invoice.slot_regs << build(:slot_reg, registerable: slot_option.optionable)
      invoice.opt_regs << build(:slot_opt_reg, registerable: slot_option)
      invoice.calc_cost
      expect(invoice.total_cost).to eq(11)
    end

    it 'does not calculate cost for options without time slot' do
      invoice.opt_regs << build(:slot_opt_reg, registerable: slot_option)
      invoice.calc_cost
      expect(invoice.total_cost).to eq(0)
    end

    it 'destroys orphan options' do
      child = create(:child)
      invoice.slot_regs << build(:slot_reg, registerable: slot_option.optionable, child: child)
      invoice.opt_regs << build(:slot_opt_reg, registerable: slot_option, child: child)
      invoice.calc_cost && invoice.save
      invoice.update(slot_regs: [])
      expect(invoice.reload.opt_regs.count).to eq(0)
    end
  end

  context 'when calculating cost for event options' do
    let(:event_option) { create(:event_option, cost: 10, optionable: event) }

    it 'calculates cost for event options if at least one activity registration' do
      invoice.slot_regs << build(:slot_reg)
      invoice.opt_regs << build(:event_opt_reg, registerable: event_option)
      invoice.calc_cost
      expect(invoice.total_cost).to eq(11)
    end

    it 'does not calculate cost for event options when no activity registrations' do
      invoice.opt_regs << build(:event_opt_reg, registerable: event_option)
      invoice.calc_cost
      expect(invoice.total_cost).to eq(0)
    end

    it 'does not charge for event option sibling is registered for' do
      parent = build(:user, children: create_list(:child, 2))
      create(:event_opt_reg, registerable: event_option, child: parent.children.first)
      invoice.opt_regs << build(:event_opt_reg, registerable: event_option, child: parent.children.last)
      invoice.calc_cost
      expect(invoice.total_cost).to eq(0)
    end
  end
end
