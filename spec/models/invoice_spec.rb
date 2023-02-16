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
    let(:slot) { create(:time_slot, event: invoice.event) }

    context 'when for member child' do
      let(:member_child) { create(:child, category: :internal) }

      def register(num)
        create_list(:slot_registration, num, invoice: invoice, registerable: slot, child: member_child)
      end

      before do
        invoice.update!(parent: parent)
        parent.children << member_child
      end

      it 'calculates cost when breakpoint is matched' do
        register(5)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 18_700
      end

      it 'calculates cost when not on breakpoint' do
        register(7)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 27_132
      end

      it 'calculates registrations much larger than course table anticipates' do
        register(69)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 233_564
      end
    end

    context 'when for non-member child' do
      let(:non_member_child) { create(:child, category: :external) }

      def register(num)
        create_list(:slot_registration, num, invoice: invoice, registerable: slot, child: non_member_child)
      end

      before do
        invoice.update!(parent: parent)
        parent.children << non_member_child
      end

      it 'calculates cost when breakpoint is matched' do
        register(5)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 30_000
      end

      it 'calculates cost when not on breakpoint' do
        register(7)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 43_200
      end

      it 'calculates registrations much larger than course table anticipates' do
        register(69)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 336_400
      end
    end

    context 'when for both member and non-member child' do
      let(:children) { [create(:child, category: :internal), create(:child, category: :external)] }

      def register(member_num, non_num)
        create_list(:slot_registration, member_num, invoice: invoice, registerable: slot, child: children[0])
        create_list(:slot_registration, non_num, invoice: invoice, registerable: slot, child: children[1])
      end

      before do
        invoice.update!(parent: parent)
        parent.update!(children: children)
      end

      it 'calculates cost when breakpoint is matched' do
        register(5, 5)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 48_700
      end

      it 'calculates cost when not on breakpoint' do
        register(7, 7)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 70_332
      end

      it 'calculates registrations much larger than course table anticipates' do
        register(69, 69)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 569_964
      end
    end

    # Since both in same category, registrations should be combined into
    # a single course
    context 'when for two member children' do
      let(:children) { create_list(:child, 2, category: :internal) }

      def register(num)
        parent.children.each do |child|
          create_list(:slot_registration, num, invoice: invoice, registerable: slot, child: child)
        end
      end

      before do
        invoice.update!(parent: parent)
        parent.update!(children: children)
      end

      it 'calculates cost when breakpoint is matched' do
        register(5)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 33_000
      end

      it 'calculates cost when not on breakpoint' do
        register(7)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 49_864
      end

      it 'calculates registrations much larger than course table anticipates' do
        register(69)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 462_364
      end
    end

    # Registrations from children in same category should be combined when
    # calculating course cost
    context 'when for two member children and two non-member children' do
      let(:children) do
        [create(:child, category: :internal),
         create(:child, category: :internal),
         create(:child, category: :external),
         create(:child, category: :external)]
      end

      def register(member_num, non_num)
        parent.children.slice(0..1).each do |child|
          create_list(:slot_registration, member_num, invoice: invoice, registerable: slot, child: child)
        end
        parent.children.slice(2..3).each do |child|
          create_list(:slot_registration, non_num, invoice: invoice, registerable: slot, child: child)
        end
      end

      before do
        invoice.update!(parent: parent)
        parent.update!(children: children)
      end

      it 'calculates cost when breakpoint is matched' do
        register(5, 5)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 88_000
      end

      it 'calculates cost when not on breakpoint' do
        register(7, 7)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 131_264
      end

      it 'calculates registrations much larger than course table anticipates' do
        register(35, 35)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 566_000
      end
    end

    context 'when member child attending for only 1 or 2 full days' do
      let(:kindy_member) { create(:child, category: :internal) }
      let(:afternoon_slot) { slot.create_afternoon_slot(attributes_for(:time_slot, event: event)) }

      def register(num)
        create_list(:slot_registration, num, invoice: invoice, registerable: slot, child: kindy_member)
        create_list(:slot_registration, num, invoice: invoice, registerable: afternoon_slot, child: kindy_member)
      end

      before do
        invoice.update!(parent: parent)
        parent.children << kindy_member
      end

      it 'correctly applies 184 yen increase for those days' do
        register(1)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 8_064
      end

      # TODO: not sure this is needed yet
      xit "doesn't apply increase if it's a regular day for that child" do
      end
    end

    context 'when options are selected' do
      let(:children) { [create(:child, category: :internal), create(:child, category: :external)] }
      let(:option) { create(:option, optionable: slot) }

      def register(slots, options)
        children.each do |child|
          create_list(:slot_registration, slots, invoice: invoice, registerable: slot, child: child)
          create_list(:option_registration, options, invoice: invoice, registerable: option, child: child)
        end
      end

      before do
        invoice.update!(parent: parent)
        parent.update!(children: children)
      end

      it 'includes options from both children' do
        register(5, 5)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 58_700
      end
    end

    context 'when adjustments are present' do
      let(:non_member_child) { create(:child, category: :external) }

      def register(num)
        create_list(:slot_registration, num, invoice: invoice, registerable: slot, child: non_member_child)
      end

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
        register(5)
        create(:adjustment, invoice: invoice, change: -5_000)
        invoice.calc_cost
        cost = invoice.total_cost
        expect(cost).to be 25_000
      end
    end

    context 'when generating cost breakdown' do
      let(:children) do
        [create(:child, category: :internal),
         create(:child, category: :external)]
      end

      before do
        invoice.update!(parent: parent)
        parent.update!(children: children)
        e_opt = create(:option, name: 'Test', cost: 1000)
        event.options << e_opt
        invoice.registrations.create!(child: children[0], registerable: slot)
        invoice.registrations.create!(child: children[0], registerable: create(:option, optionable: slot))
        invoice.registrations.create!(child: children[0], registerable: e_opt)
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
        child_cost_info = "Course cost for #{children[0].name} is 4216yen for 1 registrations.\n"
        expect(summary).to include(child_cost_info)
      end

      it 'lists registered slots' do
        summary = invoice.summary
        slot_list = "Registered for:\n- #{slot.name}\n"
        expect(summary).to include(slot_list)
      end

      it 'lists registered slot options' do
        summary = invoice.summary
        slot_option_info = "   - #{slot.options.first.name} for #{slot.options.first.cost}yen\n"
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
