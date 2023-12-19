# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invoice do
  let(:event) { create(:event) }

  context 'when using membership' do
    it 'uses member pricelist if child is member' do
      child = build(:child, category: :internal)
      invoice = build(
        :invoice,
        event: event,
        slot_regs: build_list(:slot_reg, 5, child: child),
        child: child
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(5)
    end

    it 'uses non-member pricelist (and first time adjustment) if child is not member' do
      child = build(:child, category: :external)
      invoice = build(
        :invoice,
        event: event,
        slot_regs: build_list(:slot_reg, 5, child: child),
        child: child
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(1110)
    end

    it 'does not apply first time adjustment if invoice has no registrations' do
      child = build(:child, category: :external)
      invoice = build(
        :invoice,
        event: event,
        slot_regs: [],
        child: child
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(0)
    end
  end

  context 'when num_regs does not match a course' do
    let(:child) { build(:child, category: :internal) }

    it 'calculates cost with one spot use' do
      invoice = build(
        :invoice,
        event: event,
        slot_regs: build_list(:slot_reg, 1, child: child),
        child: child
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(1)
    end

    it 'calculates cost with two spot uses' do
      invoice = build(
        :invoice,
        event: event,
        slot_regs: build_list(:slot_reg, 2, child: child),
        child: child
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(2)
    end

    it 'calculates cost with one spot use over a course' do
      rand_num_regs = [6, 51].sample
      invoice = build(
        :invoice,
        event: event,
        slot_regs: build_list(:slot_reg, rand_num_regs, child: child),
        child: child
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(rand_num_regs)
    end

    it 'calculates cost with 2 spot uses over a course' do
      rand_num_regs = [7, 52].sample
      invoice = build(
        :invoice,
        event: event,
        slot_regs: build_list(:slot_reg, rand_num_regs, child: child),
        child: child
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(rand_num_regs)
    end

    it 'calculates cost with special 3 course over a course' do
      rand_num_regs = [8, 53].sample
      invoice = build(
        :invoice,
        event: event,
        slot_regs: build_list(:slot_reg, rand_num_regs, child: child),
        child: child
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(11_900 + rand_num_regs - 3)
    end

    it 'calculates cost with 4 spot uses over a course (affected by 3 course)' do
      rand_num_regs = [9, 54].sample
      invoice = build(
        :invoice,
        event: event,
        slot_regs: build_list(:slot_reg, rand_num_regs, child: child),
        child: child
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(11_900 + rand_num_regs - 3)
    end
  end

  context 'when dealing with the (200yen) pointless price for full days' do
    let(:morning_slot) do
      slot = create(:time_slot, morning: true)
      aft_attributes = attributes_for(:time_slot)
      slot.create_afternoon_slot(aft_attributes)
      slot
    end
    let(:morning_reg) { build(:slot_reg, registerable: morning_slot) }
    let(:afternoon_reg) { build(:slot_reg, registerable: morning_slot.afternoon_slot) }

    context 'when pointless prices does not apply' do
      it 'does not apply to external kindy' do
        child = build(:child, category: :external, kindy: true)
        invoice = build(
          :invoice,
          event: event,
          child: child,
          slot_regs: [morning_reg, afternoon_reg]
        )
        invoice.calc_cost
        # Plus 1_100 because 1st time external
        expect(invoice.total_cost).to eq(1_104)
      end

      it 'does not apply if just internal and not kindy' do
        child = build(:child, category: :internal)
        invoice = build(
          :invoice,
          event: event,
          child: child,
          slot_regs: [morning_reg, afternoon_reg]
        )
        invoice.calc_cost
        expect(invoice.total_cost).to eq(2)
      end

      it 'does not apply if registrations are on separate days' do
        child = build(:child, category: :internal, kindy: true)
        afternoon_reg = build(
          :slot_reg,
          registerable: build(:time_slot, start_time: 1.day.from_now, morning: false)
        )
        invoice = build(
          :invoice,
          event: event,
          child: child,
          slot_regs: [morning_reg, afternoon_reg]
        )
        invoice.calc_cost
        expect(invoice.total_cost).to eq(2)
      end

      it 'does not apply if there is an extension option on a registered special day' do
        child = build(:child, category: :internal, kindy: true)
        extension_option = create(
          :option,
          category: 'extension',
          optionable: morning_slot
        )
        morning_slot.options << extension_option
        morning_slot.update(category: :special)
        invoice = build(
          :invoice,
          event: event,
          child: child,
          slot_regs: [morning_reg, afternoon_reg]
        )
        invoice.calc_cost
        expect(invoice.total_cost).to eq(2)
      end
    end

    context 'when pointless price applies' do
      it 'applies the pointless price when internal kindy child with 2 regs on 1 day' do
        child = build(:child, category: :internal, kindy: true)
        invoice = build(
          :invoice,
          event: event,
          child: child,
          slot_regs: [morning_reg, afternoon_reg]
        )

        invoice.calc_cost
        expect(invoice.total_cost).to eq(202)
      end
    end
  end
end
