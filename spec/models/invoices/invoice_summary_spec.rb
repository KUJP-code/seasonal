# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invoice do
  subject(:invoice) do
    build_stubbed(
      :invoice,
      event: event,
      child: child,
      slot_regs: build_list(:slot_reg, 6, registerable: slot),
      opt_regs: [build(:slot_opt_reg, registerable: slot_option),
                 build(:slot_opt_reg, registerable: slot_option),
                 build(:event_opt_reg, registerable: event_opt)],
      adjustments: [build(:adjustment, reason: 'Adjustment', change: 10)]
    )
  end

  let(:event) { create(:event) }
  let(:child) { build_stubbed(:child, category: :internal, name: 'Child', kindy: true) }
  let(:slot) { create(:time_slot, name: 'Slot', snack: false) }
  let(:event_opt) { create(:event_option, name: 'Event Option', cost: 10, optionable: event) }
  let(:slot_option) { create(:event_option, name: 'Slot Option', cost: 10, optionable: slot) }

  context 'when generating a summary' do
    before do
      invoice.calc_cost
    end

    it "contains invoice child's basic information" do
      expect(invoice.summary).to include_all %w[Child 幼児 通学生]
    end

    it 'includes course heading, count, snack info, course number and spot use' do
      expect(invoice.summary).to include_all [
        'コース:', '6円 (6回)', '5回コース: 5円', 'スポット1回(午前・15:00~18:30) x 1: 1円'
      ]
    end

    it 'gives option heading, grouped count of options by name' do
      expect(invoice.summary).to include_all [
        'オプション:', '30円 (3オプション)', 'Event Option x 1: 10円', 'Slot Option x 2: 20円'
      ]
    end

    it 'lists adjustments with reason and change' do
      expect(invoice.summary).to include_all ['調整:', 'Adjustment: 10円']
    end

    it 'lists all registered slots with options' do
      expect(invoice.summary).to include_all ['Slot', '- Slot Option: 10円']
    end

    it 'gives total cost & the official number' do
      expect(invoice.summary).to include_all [
        '合計（税込）: 46円', '登録番号: T7-0118-0103-7173'
      ]
    end
  end

  context 'when parts of summary not needed' do
    it 'does not include course heading' do
      invoice.slot_regs = []
      invoice.calc_cost
      expect(invoice.summary).not_to include_all [
        'コース:', '6円 (6回)', '5回コース: 5円', 'スポット1回(午前・15:00~18:30) x 1: 1円'
      ]
    end

    it 'does not include snack costs' do
      invoice.calc_cost
      expect(invoice.summary).not_to include('午後コースおやつ代')
    end

    it 'does not include extra costs' do
      invoice.calc_cost
      expect(invoice.summary).not_to include('追加料金')
    end

    it 'does not include options' do
      invoice.opt_regs = []
      invoice.calc_cost
      expect(invoice.summary).not_to include('オプション:')
    end

    it 'does not include adjustments' do
      invoice.adjustments = []
      invoice.calc_cost
      expect(invoice.summary).not_to include('調整:')
    end
  end

  context 'when niche cases apply' do
    it 'does displays pointless price' do
      morning_slot = create(:time_slot, morning: true)
      afternoon_slot = create(:time_slot, morning: false, morning_slot_id: morning_slot.id)
      invoice = build_stubbed(
        :invoice,
        event: event,
        child: child,
        slot_regs: [build(:slot_reg, registerable: morning_slot),
                    build(:slot_reg, registerable: afternoon_slot)]
      )
      invoice.calc_cost
      expect(invoice.summary).to include('スポット1回(13:30~18:30) x 1: 201円')
    end

    it 'displays extra costs' do
      extra_cost_slot = create(:time_slot, int_modifier: 100)
      invoice = build_stubbed(
        :invoice,
        event: event,
        child: child,
        slot_regs: [build(:slot_reg, registerable: extra_cost_slot)]
      )
      invoice.calc_cost
      expect(invoice.summary).to include('追加料金 x 1: 100円')
    end
  end
end
