# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invoice do
  subject(:invoice) do
    build_stubbed(
      :invoice,
      event:,
      child:,
      slot_regs: [build(:slot_reg, registerable: slot)],
      opt_regs: [build(:slot_opt_reg, registerable:
                         create(:slot_option, name: 'Slot Option', cost: 10, optionable: slot)),
                 build(:event_opt_reg, registerable: event_opt)],
      adjustments: [build(:adjustment, reason: 'Adjustment', change: 10)]
    )
  end

  let(:event) { create(:event) }
  let(:child) do
    build_stubbed(:child, category: :internal, name: 'Child',
                          kindy: true)
  end
  let(:slot) { create(:time_slot, name: 'Slot', snack: false, morning: false) }
  let(:event_opt) { create(:event_option, name: 'Event Option', cost: 10, optionable: event) }
  let(:spare_slot_option) do
    create(:slot_option, name: 'Spare Slot Option', cost: 10, optionable: slot)
  end

  context 'when generating a summary' do
    before do
      invoice.calc_cost
    end

    it "contains invoice child's basic information" do
      expect(invoice.summary).to include_all %w[幼児 通学生]
    end

    it 'includes course heading and count with course name' do
      expect(invoice.summary).to include('コース:')
      expect(invoice.summary).to include('1回コース x 1: 1円')
      expect(invoice.summary).not_to include('1円 (1回)')
    end

    it 'gives option heading, grouped count of options by name' do
      expect(invoice.summary).to include('オプション:')
      expect(invoice.summary).to include('Event Option x 1: 10円')
      expect(invoice.summary).to include('Slot Option x 1: 10円')
      expect(invoice.summary).not_to include('20円 (2オプション)')
    end

    it 'lists adjustments with reason and change' do
      expect(invoice.summary).to include_all ['調整:', 'Adjustment: 10円']
    end

    it 'lists all registered slots with options' do
      expect(invoice.summary).to include_all ['Slot', '- Slot Option: 10円']
    end

    it 'tags afternoon slots as "(午後)"' do
      expect(invoice.summary).to include('午後').once
    end

    it 'does not list unregistered options for registered slots' do
      expect(invoice.summary).not_to include(spare_slot_option.name)
    end

    it 'gives total cost' do
      expect(invoice.summary).to include('合計（税込）: 31円')
    end
  end

  context 'when parts of summary not needed' do
    it 'does not include course heading' do
      invoice.slot_regs = []
      invoice.calc_cost
      expect(invoice.summary).not_to include_all [
        'コース:', '6円 (6回)', '5回コース: 5円', '1回コース x 1: 1円'
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
    it 'displays extra costs' do
      extra_cost_slot = create(:time_slot, int_modifier: 100)
      invoice = build_stubbed(
        :invoice,
        event:,
        child:,
        slot_regs: [build(:slot_reg, registerable: extra_cost_slot)]
      )
      invoice.calc_cost
      expect(invoice.summary).to include('追加料金 x 1: 100円')
    end
  end

  context 'when summarising a party' do
    it 'displays event * 1 = 1 course rather than usual course section' do
      invoice = build_stubbed(
        :invoice,
        event: create(:event, early_bird_discount: -500),
        slot_regs: [build(:slot_reg, registerable: slot)]
      )
      invoice.calc_cost
      expect(invoice.summary).to include('イベント x 1: 1円')
    end

    it 'displays event * n = 1 course * n when multiple parties attended' do
      invoice = build_stubbed(
        :invoice,
        event: create(:event, early_bird_discount: -500),
        slot_regs: [build(:slot_reg, registerable: slot),
                    build(:slot_reg, registerable: create(:time_slot))]
      )
      invoice.calc_cost
      expect(invoice.summary).to include('イベント x 2: 2円')
    end
  end
end
