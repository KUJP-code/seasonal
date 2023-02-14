# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invoice do
  subject(:invoice) { create(:invoice, event: event) }

  let(:event) { create(:event, member_price: create(:member_price), non_member_price: create(:non_member_price)) }

  context 'when valid' do
    it 'saves' do
      valid_invoice = build(:invoice)
      valid = valid_invoice.save!
      expect(valid).to be true
    end
  end

  context 'when invalid' do
    it 'no event' do
      no_event = build(:invoice, event: nil)
      valid = no_event.save
      expect(valid).to be false
    end

    it 'no parent' do
      no_parent = build(:invoice, parent: nil)
      valid = no_parent.save
      expect(valid).to be false
    end

    it 'total cost not a number' do
      word_cost = build(:invoice, total_cost: 'spaghetti')
      valid = word_cost.save
      expect(valid).to be false
    end

    it 'total cost less than 0' do
      neg_cost = build(:invoice, total_cost: -100)
      valid = neg_cost.save
      expect(valid).to be false
    end
  end

  context 'with parent' do
    let(:parent) { create(:customer_user) }

    it 'knows its parent' do
      invoice = build(:invoice, parent: parent)
      invoice_parent = invoice.parent
      expect(invoice_parent).to eq parent
    end

    it 'parent knows it' do
      invoice = parent.invoices.create!(attributes_for(:invoice))
      parent_invoices = parent.invoices
      expect(parent_invoices).to contain_exactly(invoice)
    end

    context 'with children through parent' do
      let(:children) { create_list(:child, 2) }

      before do
        parent.children = children
      end

      it 'knows its children' do
        invoice = parent.invoices.create!(attributes_for(:invoice))
        invoice_children = invoice.children
        expect(invoice_children).to match_array(children)
      end

      it 'children know it' do
        invoice = parent.invoices.create!(attributes_for(:invoice))
        child_invoices = children.first.invoices
        expect(child_invoices).to contain_exactly invoice
      end
    end
  end

  context 'with event' do
    let(:event) { create(:event) }

    it 'knows its event' do
      invoice = build(:invoice, event: event)
      invoice_event = invoice.event
      expect(invoice_event).to eq event
    end

    it 'event knows it' do
      invoice = event.invoices.create!(attributes_for(:invoice))
      event_invoices = event.invoices
      expect(event_invoices).to contain_exactly(invoice)
    end
  end

  context 'with registrations' do
    it 'knows its registrations' do
      regs = create_list(:slot_registration, 2, invoice: invoice)
      invoice_regs = invoice.registrations
      expect(invoice_regs).to match_array regs
    end

    it 'registrations know it' do
      reg = create(:option_registration, invoice: invoice)
      reg_invoice = reg.invoice
      expect(reg_invoice).to eq invoice
    end
  end

  context 'when calculating total cost' do
    let(:parent) { create(:customer_user) }
    let(:member_child) { create(:child, category: :internal) }
    let(:non_member_child) { create(:child, category: :external) }

    # Simplify creating registrations for member/non_member kids
    def register(type, member_num, non_member_num)
      slot = create(:time_slot)

      case type
      when :slot
        create_list(:slot_registration, member_num, invoice: invoice, registerable: slot, child: member_child)
        create_list(:slot_registration, non_member_num, invoice: invoice, registerable: slot, child: non_member_child)
      when :option
        option = create(:option, optionable: slot)
        create_list(:option_registration, member_num + non_member_num,
                    invoice: invoice, registerable: option, child: non_member_child)
      end
    end

    context 'when for member child' do
      before do
        invoice.update!(parent: parent)
        parent.children << member_child
      end

      it 'calculates cost when breakpoint is matched' do
        register(:slot, 5, 0)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 18_700
      end

      it 'calculates cost when not on breakpoint' do
        register(:slot, 7, 0)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 27_132
      end

      it 'calculates registrations much larger than course table anticipates' do
        register(:slot, 69, 0)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 233_564
      end
    end

    context 'when for non-member child' do
      before do
        invoice.update!(parent: parent)
        parent.children << non_member_child
      end

      it 'calculates cost when breakpoint is matched' do
        register(:slot, 0, 5)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 30_000
      end

      it 'calculates cost when not on breakpoint' do
        register(:slot, 0, 7)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 43_200
      end

      it 'calculates registrations much larger than course table anticipates' do
        register(:slot, 0, 69)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 336_400
      end
    end

    context 'when for both member and non-member child' do
      before do
        invoice.update!(parent: parent)
        parent.update!(children: [member_child, non_member_child])
      end

      it 'calculates cost when breakpoint is matched' do
        register(:slot, 5, 5)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 48_700
      end

      it 'calculates cost when not on breakpoint' do
        register(:slot, 7, 7)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 70_332
      end

      it 'calculates registrations much larger than course table anticipates' do
        register(:slot, 69, 69)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 569_964
      end
    end

    context 'when options are selected' do
      before do
        invoice.update!(parent: parent)
        parent.children << non_member_child
      end

      it 'includes options from member child' do
        register(:slot, 0, 5)
        register(:option, 10, 0)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 40_000
      end

      it 'includes options from non member child' do
        register(:slot, 0, 5)
        register(:option, 0, 7)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 37_000
      end

      it 'includes options from both children' do
        register(:slot, 0, 5)
        register(:option, 5, 7)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 42_000
      end
    end

    context 'when adjustments are present' do
      before do
        invoice.update!(parent: parent)
        parent.children << non_member_child
      end

      it 'invoice knows its adjustments' do
        adjustment = create(:adjustment, invoice: invoice)
        invoice_adjustments = invoice.adjustments
        expect(invoice_adjustments).to contain_exactly(adjustment)
      end

      it 'includes adjustments in the calculation' do
        register(:slot, 0, 5)
        create(:adjustment, invoice: invoice, change: -5_000)
        invoice.calc_cost
        cost = invoice.total_cost
        expect(cost).to be 25_000
      end
    end

    context 'when generating cost breakdown' do
      let(:time_slot) { create(:time_slot) }

      before do
        invoice.update!(parent: parent)
        parent.update!(children: [member_child, non_member_child])
        e_opt = create(:option, name: 'Test', cost: 1000)
        event.options << e_opt
        invoice.registrations.create!(child: member_child, registerable: time_slot)
        invoice.registrations.create!(child: member_child, registerable: create(:option, optionable: time_slot))
        invoice.registrations.create!(child: member_child, registerable: e_opt)
        invoice.calc_cost
      end

      it 'gives invoice number, customer name and event' do
        summary = invoice.summary
        key_info = "Invoice##{invoice.id}\nCustomer: #{parent.name}\nEvent: #{event.name}\n"
        expect(summary).to include(key_info)
      end

      it 'lists event options' do
        summary = invoice.summary
        e_opt_info = " - Test for 1000\n"
        expect(summary).to include(e_opt_info)
      end

      it 'gives cost per child' do
        summary = invoice.summary
        child_cost_info = "Your course cost for #{member_child.name} is 4216yen for 1 registrations.\n"
        expect(summary).to include(child_cost_info)
      end

      it 'lists registered slots' do
        summary = invoice.summary
        slot_list = "Registered for:\n- #{time_slot.name}\n"
        expect(summary).to include(slot_list)
      end

      it 'lists registered slot options' do
        summary = invoice.summary
        slot_option_info = "   - #{time_slot.options.first.name} for #{time_slot.options.first.cost}yen\n"
        expect(summary).to include(slot_option_info)
      end

      it 'gives a total cost' do
        summary = invoice.summary
        final_cost = 'Your final total is 6216'
        expect(summary).to include(final_cost)
      end
    end
  end
end
