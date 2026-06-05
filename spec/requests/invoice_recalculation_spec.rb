# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Invoice recalculation' do
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
           member_prices:)
  end
  let(:child) { create(:child, category: :internal) }

  def slot_attributes(slots, child)
    slots.map do |slot|
      { child_id: child.id,
        registerable_id: slot.id,
        registerable_type: 'TimeSlot' }
    end
  end

  def destroyed_slot_attributes(regs)
    regs.map do |reg|
      { id: reg.id,
        child_id: reg.child_id,
        pricing_batch: reg.pricing_batch,
        registerable_id: reg.registerable_id,
        registerable_type: reg.registerable_type,
        _destroy: '1' }
    end
  end

  def split_batch_invoice
    initial_slots = create_list(:time_slot, 10, event:)
    invoice = create(:invoice,
                     event:,
                     child:,
                     slot_regs_attributes: slot_attributes(initial_slots, child))
    invoice.assign_attributes(
      slot_regs_attributes: destroyed_slot_attributes([invoice.slot_regs.first])
    )
    invoice.save!

    replacement_slot = create(:time_slot, event:)
    invoice.assign_attributes(slot_regs_attributes: slot_attributes([replacement_slot], child))
    invoice.save!
    invoice
  end

  it 'allows admins to force the current activities into one pricing batch' do
    invoice = split_batch_invoice
    expect(invoice.total_cost).not_to eq(member_prices.courses['10'])

    sign_in create(:admin)
    patch recalculate_invoice_path(id: invoice.id)

    expect(response).to redirect_to(invoice_path(id: invoice.id))
    expect(invoice.reload.total_cost).to eq(member_prices.courses['10'])
    expect(invoice.slot_regs.map(&:pricing_batch).uniq).to eq([1])
  end

  it 'does not allow non-admin staff to recalculate pricing batches' do
    invoice = split_batch_invoice
    original_cost = invoice.total_cost
    original_batches = invoice.slot_regs.map(&:pricing_batch)

    sign_in create(:school_manager, allowed_ips: ['*'])
    patch recalculate_invoice_path(id: invoice.id)

    expect(response).to redirect_to(root_path(locale: I18n.locale))
    expect(invoice.reload.total_cost).to eq(original_cost)
    expect(invoice.slot_regs.map(&:pricing_batch)).to match_array(original_batches)
  end
end
