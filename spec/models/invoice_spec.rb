# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invoice do
  subject(:invoice) { create(:invoice, event: event) }

  let(:event) { create(:event, member_prices: create(:member_prices), non_member_prices: create(:non_member_prices)) }

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

    it 'no child' do
      no_child = build(:invoice, child: nil)
      valid = no_child.save
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

  context 'with child' do
    let(:child) { create(:child, parent: create(:customer_user)) }

    it 'knows its child' do
      invoice = child.invoices.create(attributes_for(:invoice))
      invoice_child = invoice.child
      expect(invoice_child).to eq child
    end

    context 'with parent through child' do
      it 'knows its parent' do
        parent = child.parent
        invoice = child.invoices.create(attributes_for(:invoice))
        invoice_parent = invoice.parent
        expect(invoice_parent).to eq parent
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
    let(:slot) { create(:time_slot, event: invoice.event, morning: true) }

    context 'when for member child' do
      let(:member_child) { create(:child, category: :internal) }

      def register(num)
        create_list(:slot_registration, num, invoice: invoice, registerable: slot, child: member_child)
      end

      before do
        invoice.update!(child: member_child)
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
        invoice.update!(child: non_member_child)
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

    context 'when member child attending for only 1 or 2 full days' do
      let(:kindy_member) { create(:child, category: :internal, level: :kindy) }

      def register(num)
        num.times do
          morning_slot = create(:time_slot, morning: true, event: event)
          kindy_member.registrations.create!(invoice: invoice, registerable: morning_slot)

          afternoon_slot = morning_slot.create_afternoon_slot(attributes_for(:time_slot, event: event))
          kindy_member.registrations.create!(invoice: invoice, registerable: afternoon_slot)
        end
      end

      before do
        invoice.update!(child: kindy_member)
      end

      it 'correctly applies 184 yen increase for one full day' do
        register(1)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 8_616
      end

      it 'correctly applies 184 yen increase for two full days' do
        register(2)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 17_232
      end
    end

    context 'when options are selected' do
      let(:child) { create(:child, category: :external) }
      let(:option) { create(:option, optionable: slot, cost: 100) }

      def register(slots, options)
        create_list(:slot_registration, slots, invoice: invoice, registerable: slot, child: child)
        create_list(:option_registration, options, invoice: invoice, registerable: option, child: child)
      end

      before do
        invoice.update!(child: child)
      end

      it 'includes options' do
        register(5, 5)
        invoice.calc_cost
        total_cost = invoice.total_cost
        expect(total_cost).to be 30_500
      end
    end

    context 'when adjustments are present' do
      let(:non_member_child) { create(:child, category: :external) }

      def register(num)
        create_list(:slot_registration, num, invoice: invoice, registerable: slot, child: non_member_child)
      end

      before do
        invoice.update!(child: non_member_child)
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

    # TODO: re-write once the message is finalised
    # context 'when generating cost breakdown' do
    #   let(:children) do
    #     [create(:child, category: :internal),
    #      create(:child, category: :external)]
    #   end

    #   before do
    #     invoice.update!(parent: parent)
    #     parent.update!(children: children)
    #     e_opt = create(:option, name: 'Test', cost: 1000)
    #     event.options << e_opt
    #     invoice.registrations.create!(child: children[0], registerable: slot)
    #     invoice.registrations.create!(child: children[0], registerable: create(:option, optionable: slot))
    #     invoice.registrations.create!(child: children[0], registerable: e_opt)
    #     invoice.calc_cost
    #   end

    #   it 'gives invoice number, customer name and event' do
    #     summary = invoice.summary
    #     key_info = "Invoice: #{invoice.id}\nCustomer: #{parent.name}\nFor #{event.name} at #{event.school.name}\n"
    #     expect(summary).to include(key_info)
    #   end

    #   it 'lists event options' do
    #     summary = invoice.summary
    #     e_opt_info = "- Test: 1000yen\n"
    #     expect(summary).to include(e_opt_info)
    #   end

    #   it 'lists registered slots' do
    #     summary = invoice.summary
    #     slot_list = "- #{slot.name}\n"
    #     expect(summary).to include(slot_list)
    #   end

    #   it 'lists registered slot options' do
    #     summary = invoice.summary
    #     slot_option_info = " - #{slot.options.first.name}: #{slot.options.first.cost}\n"
    #     expect(summary).to include(slot_option_info)
    #   end

    #   it 'gives a total cost' do
    #     summary = invoice.summary
    #     final_cost = "\nFinal cost is 6216"
    #     expect(summary).to include(final_cost)
    #   end
    # end
  end
end
