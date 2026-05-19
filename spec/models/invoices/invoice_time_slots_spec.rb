# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invoice do
  let(:member_prices) do
    create(:member_prices, course1: '5_000', course3: '11_900', course5: '19_600',
                           course10: '34_600', course15: '51_900', course20: '69_200',
                           course25: '86_500', course30: '103_800', course35: '121_000',
                           course40: '138_800', course45: '155_000', course50: '170_000')
  end
  let(:non_member_prices) do
    create(:non_member_prices, course1: '6_930', course3: '19_100', course5: '31_500',
                               course10: '57_750', course15: '84_000', course20: '105_000',
                               course25: '126_000', course30: '147_000', course35: '164_500',
                               course40: '180_000', course45: '193_500', course50: '205_000')
  end
  let(:event) do
    create(:event,
           start_date: Date.new(2026, 4, 1),
           end_date: Date.new(2026, 4, 2),
           member_prices:,
           non_member_prices:)
  end

  context 'when using membership' do
    it 'uses member pricelist if child is member' do
      child = build(:child, category: :internal)
      invoice = build(
        :invoice,
        event:,
        slot_regs: [build(:slot_reg, child:, registerable: create(:time_slot))],
        child:
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(member_prices.courses['1'])
    end

    it 'uses non-member pricelist (and first time adjustment) if child is not member' do
      child = build(:child, category: :external)
      invoice = build(
        :invoice,
        event:,
        slot_regs: [build(:slot_reg, child:, registerable: create(:time_slot))],
        child:
      )
      invoice.calc_cost
      first_time_adj = 1_100
      expect(invoice.total_cost).to eq(first_time_adj + non_member_prices.courses['1'])
    end

    it 'does not apply first time adjustment if invoice has no registrations' do
      child = build(:child, category: :external)
      invoice = build(
        :invoice,
        event:,
        slot_regs: [],
        child:
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
        event:,
        slot_regs:
          [build(:slot_reg, child:, registerable: create(:time_slot))],
        child:
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(member_prices.courses['1'])
    end

    it 'calculates cost with two spot uses' do
      slots = create_list(:time_slot, 2)
      invoice = build(
        :invoice,
        event:,
        slot_regs: slots.map { |s| build(:slot_reg, child:, registerable: s) },
        child:
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(member_prices.courses['1'] * 2)
    end

    it 'calculates cost with one spot use over a course' do
      slots = create_list(:time_slot, 6)
      invoice = build(
        :invoice,
        event:,
        slot_regs: slots.map { |s| build(:slot_reg, child:, registerable: s) },
        child:
      )
      invoice.calc_cost
      expected_cost = member_prices.courses['1'] + member_prices.courses['5']
      expect(invoice.total_cost).to eq(expected_cost)
    end

    it 'handles registrations beyond price list' do
      slots = create_list(:time_slot, 56)
      invoice = build(
        :invoice,
        event:,
        slot_regs: slots.map { |s| build(:slot_reg, child:, registerable: s) },
        child:
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(
        member_prices.courses['50'] + member_prices.courses['5'] + member_prices.courses['1']
      )
    end
  end

  context 'when calculating snack cost' do
    it 'applies snack cost for each slot where snack boolean is true' do
      snack_slot = create(:time_slot, event:, snack: true)
      no_snack_slot = create(:time_slot, event:, snack: false)
      invoice = build(
        :invoice,
        event:,
        slot_regs: [build(:slot_reg, registerable: snack_slot),
                    build(:slot_reg, registerable: no_snack_slot)]
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(TimeSlot.snack_cost_for(event) + (member_prices.courses['1'] * 2))
    end
  end

  context 'when calculating int/ext kindy/ele modifiers' do
    it 'applies internal modifier if kid is internal' do
      int_modifier = 10
      child = build(:child, category: :internal)
      slot = create(:time_slot, int_modifier:)
      invoice = build(
        :invoice,
        event:,
        child:,
        slot_regs: [build(:slot_reg, registerable: slot)]
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(member_prices.courses['1'] + int_modifier)
    end

    it 'applies external modifier if kid is external' do
      ext_modifier = 10
      child = build(:child, category: :external)
      slot = create(:time_slot, ext_modifier:)
      invoice = build(
        :invoice,
        event:,
        child:,
        slot_regs: [build(:slot_reg, registerable: slot)]
      )
      invoice.calc_cost
      first_time_adj = 1_100
      expect(invoice.total_cost).to eq(
        first_time_adj + non_member_prices.courses['1'] + ext_modifier
      )
    end

    it 'applies kindy modifier if kid is kindy' do
      kindy_modifier = 10
      child = build(:child, kindy: true, category: :internal)
      slot = create(:time_slot, kindy_modifier:)
      invoice = build(
        :invoice,
        event:,
        child:,
        slot_regs: [build(:slot_reg, registerable: slot)]
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(member_prices.courses['1'] + kindy_modifier)
    end

    it 'applies ele modifier if kid is elementary' do
      ele_modifier = 10
      child = build(:child, kindy: false, category: :internal)
      slot = create(:time_slot, ele_modifier:)
      invoice = build(
        :invoice,
        event:,
        child:,
        slot_regs: [build(:slot_reg, registerable: slot)]
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(member_prices.courses['1'] + ele_modifier)
    end

    it 'applies both kindy/ele and int/ext modifiers if both apply' do
      kindy_modifier = 10
      ext_modifier = 10
      first_time_adj = 1_100
      child = build(:child, kindy: true, category: :external)
      slot = create(:time_slot, kindy_modifier:, ext_modifier:)
      invoice = build(
        :invoice,
        event:,
        child:,
        slot_regs: [build(:slot_reg, registerable: slot)]
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(
        non_member_prices.courses['1'] + kindy_modifier + ext_modifier + first_time_adj
      )
    end

    it 'does not apply modifiers multiple times if modified and non-modified slots mixed' do
      kindy_modifier = 10
      child = build(:child, kindy: true, category: :external)
      modifier_slot = create(:time_slot, kindy_modifier:)
      non_modifier_slot = create(:time_slot)
      invoice = build(
        :invoice,
        event:,
        child:,
        slot_regs: [build(:slot_reg, registerable: modifier_slot),
                    build(:slot_reg, registerable: non_modifier_slot)]
      )
      invoice.calc_cost
      first_time_adj = 1_100
      expect(invoice.total_cost).to eq(
        (non_member_prices.courses['1'] * 2) + kindy_modifier + first_time_adj
      )
    end
  end

  context 'when not all courses present' do
    let(:child) { build(:child, category: :internal) }

    it 'can handle missing 3 course when > 3 slots registered' do
      member_prices.update(course3: '')
      time_slots = create_list(:time_slot, 4)
      invoice = build(
        :invoice,
        event:,
        slot_regs: time_slots.map { |s| build(:slot_reg, child:, registerable: s) },
        child:
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(member_prices.courses['1'] * 4)
    end

    it 'can handle missing 3 course when < 3 slots registered' do
      member_prices.update(course3: '')
      time_slots = create_list(:time_slot, 2)
      invoice = build(
        :invoice,
        event:,
        slot_regs: time_slots.map { |s| build(:slot_reg, child:, registerable: s) },
        child:
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(member_prices.courses['1'] * 2)
    end

    it 'falls back to spot use if 3 course missing' do
      member_prices.update(course3: '')
      time_slots = create_list(:time_slot, 3)
      invoice = build(
        :invoice,
        event:,
        slot_regs: time_slots.map { |s| build(:slot_reg, child:, registerable: s) },
        child:
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(member_prices.courses['1'] * 3)
    end

    it 'can handle missing 5 course when > 5 slots registered' do
      member_prices.update(course5: '')
      time_slots = create_list(:time_slot, 6)
      invoice = build(
        :invoice,
        event:,
        slot_regs: time_slots.map { |s| build(:slot_reg, child:, registerable: s) },
        child:
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(member_prices.courses['3'] * 2)
    end

    it 'can handle missing 5 course when < 5 slots registered' do
      member_prices.update(course5: '')
      time_slots = create_list(:time_slot, 4)
      invoice = build(
        :invoice,
        event:,
        slot_regs: time_slots.map { |s| build(:slot_reg, child:, registerable: s) },
        child:
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(member_prices.courses['1'] + member_prices.courses['3'])
    end

    it 'falls back to spot use if 5 course missing' do
      member_prices.update(course5: '')
      time_slots = create_list(:time_slot, 5)
      invoice = build(
        :invoice,
        event:,
        slot_regs: time_slots.map { |s| build(:slot_reg, child:, registerable: s) },
        child:
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(
        (member_prices.courses['1'] * 2) + member_prices.courses['3']
      )
    end

    it 'handles both 3 & 5 course missing' do
      member_prices.update(course3: '', course5: '')
      time_slots = create_list(:time_slot, 6)
      invoice = build(
        :invoice,
        event:,
        slot_regs: time_slots.map { |s| build(:slot_reg, child:, registerable: s) },
        child:
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(member_prices.courses['1'] * 6)
    end

    it 'can handle missing 10 course when > 10 slots registered' do
      member_prices.update(course10: '')
      time_slots = create_list(:time_slot, 11)
      invoice = build(
        :invoice,
        event:,
        slot_regs: time_slots.map { |s| build(:slot_reg, child:, registerable: s) },
        child:
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(
        (member_prices.courses['5'] * 2) + member_prices.courses['1']
      )
    end

    it 'can handle missing 10 course when < 10 slots registered' do
      member_prices.update(course10: '')
      time_slots = create_list(:time_slot, 8)
      invoice = build(
        :invoice,
        event:,
        slot_regs: time_slots.map { |s| build(:slot_reg, child:, registerable: s) },
        child:
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(member_prices.courses['5'] + member_prices.courses['3'])
    end

    it 'falls back to smaller courses comboed if 10 course missing' do
      member_prices.update(course10: '')
      time_slots = create_list(:time_slot, 10)
      invoice = build(
        :invoice,
        event:,
        slot_regs: time_slots.map { |s| build(:slot_reg, child:, registerable: s) },
        child:
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(member_prices.courses['5'] * 2)
    end

    it 'can handle missing 50 course when > 50 slots registered' do
      member_prices.update(course50: '')
      time_slots = create_list(:time_slot, 51)
      invoice = build(
        :invoice,
        event:,
        slot_regs: time_slots.map { |s| build(:slot_reg, child:, registerable: s) },
        child:
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(
        member_prices.courses['45'] + member_prices.courses['1'] + member_prices.courses['5']
      )
    end

    it 'can handle missing 50 course when < 50 slots registered' do
      member_prices.update(course50: '')
      time_slots = create_list(:time_slot, 48)
      invoice = build(
        :invoice,
        event:,
        slot_regs: time_slots.map { |s| build(:slot_reg, child:, registerable: s) },
        child:
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(member_prices.courses['45'] + member_prices.courses['3'])
    end

    it 'falls back to smaller courses comboed if 50 course missing' do
      member_prices.update(course50: '')
      time_slots = create_list(:time_slot, 50)
      invoice = build(
        :invoice,
        event:,
        slot_regs: time_slots.map { |s| build(:slot_reg, child:, registerable: s) },
        child:
      )
      invoice.calc_cost
      expect(invoice.total_cost).to eq(member_prices.courses['45'] + member_prices.courses['5'])
    end
  end

  context 'when using 2026 pricing rules' do
    let(:member_prices) do
      create(:member_prices, course1: '5_000', course3: '', course5: '19_600',
                             course10: '34_600', course15: '', course20: '',
                             course25: '', course30: '', course35: '',
                             course40: '', course45: '', course50: '')
    end
    let(:event) do
      create(:event,
             start_date: Date.new(2026, 5, 1),
             end_date: Date.new(2026, 5, 2),
             member_prices:,
             non_member_prices:)
    end
    let(:child) { create(:child, category: :internal) }

    def slot_attributes(slots, child)
      slots.map do |slot|
        { child_id: child.id,
          registerable_id: slot.id,
          registerable_type: 'TimeSlot' }
      end
    end

    def persisted_slot_attributes(regs)
      regs.map do |reg|
        { id: reg.id,
          child_id: reg.child_id,
          pricing_batch: reg.pricing_batch,
          registerable_id: reg.registerable_id,
          registerable_type: reg.registerable_type }
      end
    end

    it 'prices three activities as three single courses' do
      slots = create_list(:time_slot, 3, event:)
      invoice = create(:invoice,
                       event:,
                       child:,
                       slot_regs_attributes: slot_attributes(slots, child))

      expect(invoice.total_cost).to eq(member_prices.courses['1'] * 3)
    end

    it 'does not rebundle existing invoice activities with later additions' do
      initial_slots = create_list(:time_slot, 3, event:)
      invoice = create(:invoice,
                       event:,
                       child:,
                       slot_regs_attributes: slot_attributes(initial_slots, child))

      new_slots = create_list(:time_slot, 2, event:)
      invoice.assign_attributes(slot_regs_attributes: slot_attributes(new_slots, child))
      invoice.save!

      expect(invoice.total_cost).to eq(member_prices.courses['1'] * 5)
    end

    it 'does not rebundle existing activities with later additions in the confirmation preview' do
      initial_slots = create_list(:time_slot, 4, event:)
      invoice = create(:invoice,
                       event:,
                       child:,
                       slot_regs_attributes: slot_attributes(initial_slots, child))
      new_slot = create(:time_slot, event:)
      preview = Invoice.new(
        id: invoice.id,
        event:,
        child:,
        slot_regs_attributes: persisted_slot_attributes(invoice.slot_regs) +
                              slot_attributes([new_slot], child)
      )

      preview.calc_cost

      expect(preview.total_cost).to eq(member_prices.courses['1'] * 5)
      expect(preview.summary).to include('1回コース x 4')
      expect(preview.summary).to include('1回コース x 1')
    end

    it 'prices five activities added together as one five course' do
      slots = create_list(:time_slot, 5, event:)
      invoice = create(:invoice,
                       event:,
                       child:,
                       slot_regs_attributes: slot_attributes(slots, child))

      expect(invoice.total_cost).to eq(member_prices.courses['5'])
    end

    it 'prices five fresh activities as one five course after previous activities are removed' do
      initial_slots = create_list(:time_slot, 3, event:)
      invoice = create(:invoice,
                       event:,
                       child:,
                       slot_regs_attributes: slot_attributes(initial_slots, child))
      invoice.slot_regs.destroy_all
      invoice.reload.save!
      invoice.update!(in_ss: true)
      invoice.update!(in_ss: false)

      fresh_slots = create_list(:time_slot, 5, event:)
      invoice.assign_attributes(slot_regs_attributes: slot_attributes(fresh_slots, child))
      invoice.save!

      expect(invoice.total_cost).to eq(member_prices.courses['5'])
    end

    it 'uses the populated price list packages' do
      slots = create_list(:time_slot, 29, event:)
      invoice = create(:invoice,
                       event:,
                       child:,
                       slot_regs_attributes: slot_attributes(slots, child))

      expected_cost = (member_prices.courses['10'] * 2) +
                      member_prices.courses['5'] +
                      (member_prices.courses['1'] * 4)
      expect(invoice.total_cost).to eq(expected_cost)
    end

    it 'allows future price lists to add another package' do
      member_prices.update!(course3: '11_900')
      slots = create_list(:time_slot, 29, event:)
      invoice = create(:invoice,
                       event:,
                       child:,
                       slot_regs_attributes: slot_attributes(slots, child))

      expected_cost = (member_prices.courses['10'] * 2) +
                      member_prices.courses['5'] +
                      member_prices.courses['3'] +
                      member_prices.courses['1']
      expect(invoice.total_cost).to eq(expected_cost)
    end
  end
end
