# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invoice do
  let(:event) { create(:event) }
  let(:invoice) { build(:invoice, event:) }

  context 'when calculating cost for slot options' do
    let(:slot_option) { create(:slot_option, cost: 10) }

    it 'calculates cost with option on time slot' do
      invoice.slot_regs =
        [create(:slot_reg, registerable: slot_option.optionable, invoice:)]
      invoice.opt_regs =
        [create(:slot_opt_reg, registerable: slot_option, invoice:)]
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
      invoice.slot_regs <<
        build(:slot_reg, registerable: slot_option.optionable, child:)
      invoice.opt_regs <<
        build(:slot_opt_reg, registerable: slot_option, child:)
      invoice.calc_cost && invoice.save
      invoice.update(slot_regs: [])
      expect(invoice.reload.opt_regs.count).to eq(0)
    end
  end

  context 'when calculating cost for event options' do
    let(:event) do
      create(:event,
             start_date: Date.new(2025, 8, 1),
             end_date: Date.new(2025, 8, 2),
             early_bird_date: Date.new(2025, 7, 1))
    end
    let(:event_option) { create(:event_option, cost: 10, optionable: event) }

    it 'calculates cost for event options if at least one slot registered' do
      invoice.slot_regs << build(:slot_reg, registerable: create(:time_slot))
      invoice.opt_regs << build(:event_opt_reg, registerable: event_option)
      invoice.calc_cost
      expect(invoice.total_cost).to eq(11)
    end

    it 'calculates cost for event options when no activity registrations' do
      invoice.opt_regs << build(:event_opt_reg, registerable: event_option)
      invoice.calc_cost
      expect(invoice.total_cost).to eq(10)
    end

    it 'does not charge for event option sibling is registered for' do
      parent = build(:user)
      children = create_list(:child, 2, parent:)
      create(:event_opt_reg, registerable: event_option, child: children.first)
      invoice.child = children.last
      invoice.opt_regs << build(:event_opt_reg, registerable: event_option,
                                                child: children.last)
      invoice.calc_cost
      expect(invoice.total_cost).to eq(0)
    end
  end
end
