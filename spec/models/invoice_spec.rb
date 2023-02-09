# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invoice do
  subject(:invoice) { create(:invoice) }

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

    it 'no total cost' do
      no_cost = build(:invoice, total_cost: nil)
      valid = no_cost.save
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
end
