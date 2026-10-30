# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Invoice photo-service eligibility' do
  let(:event) { create(:event, start_date: Date.new(2026, 12, 1), end_date: Date.new(2027, 1, 31)) }
  let(:child) { create(:internal_child, parent: create(:customer)) }
  let(:photo) { create(:event_option, optionable: event, name: 'Photo service', cost: 1000) }
  let(:afternoon) { create(:time_slot, :afternoon, event:, snack: false) }
  let(:morning) { create(:time_slot, :morning, event:) }

  def invoice_with_photo(slots)
    create(:invoice, event:, child:,
                     slot_regs_attributes: slots.map { |slot| { child_id: child.id, registerable: slot } },
                     opt_regs_attributes: [{ child_id: child.id, registerable_id: photo.id,
                                             registerable_type: 'Option' }])
  end

  it 'ignores submitted photo service for regular afternoon-only bookings' do
    invoice = invoice_with_photo([afternoon])

    expect(invoice.total_cost).to eq(event.member_prices.courses['1'])
    expect(invoice.opt_regs).to be_empty
    expect(invoice.summary).not_to include(photo.name)
  end

  it 'rejects photo service without any activity bookings' do
    invoice = invoice_with_photo([])

    expect(invoice.total_cost).to eq(0)
    expect(invoice.opt_regs).to be_empty
  end

  it 'charges photo service for morning bookings' do
    invoice = invoice_with_photo([morning])

    expect(invoice.total_cost).to eq(event.member_prices.courses['1'] + photo.cost)
    expect(invoice.opt_regs.map(&:registerable_id)).to eq([photo.id])
  end

  it 'charges photo service for special afternoon activities' do
    afternoon.update!(category: :special)

    expect(invoice_with_photo([afternoon]).total_cost).to eq(event.member_prices.courses['1'] + photo.cost)
  end

  it 'removes photo service when the last eligible activity is removed' do
    invoice = invoice_with_photo([morning, afternoon])
    reg = invoice.slot_regs.find_by!(registerable_id: morning.id)
    invoice.update!(slot_regs_attributes: [{ id: reg.id, _destroy: '1' }])

    expect(invoice.reload.opt_regs).to be_empty
    expect(invoice.total_cost).to eq(event.member_prices.courses['1'])
    expect(invoice.summary).not_to include(photo.name)
  end

  it 'recognizes eligible activities on another confirmed invoice for the same child and event' do
    create(:invoice, child:, event:, in_ss: true,
                     slot_regs_attributes: [{ child_id: child.id, registerable: morning }])

    expect(invoice_with_photo([afternoon]).total_cost).to eq(event.member_prices.courses['1'] + photo.cost)
  end

  it 'does not borrow eligibility from a different event' do
    other = create(:event)
    other_morning = create(:time_slot, :morning, event: other)
    create(:invoice, child:, event: other,
                     slot_regs_attributes: [{ child_id: child.id, registerable: other_morning }])

    expect(invoice_with_photo([afternoon]).opt_regs).to be_empty
  end

  it 'removes a legacy photo charge from a confirmed afternoon-only invoice during explicit recalculation' do
    invoice = create(:invoice, child:, event:,
                     slot_regs_attributes: [{ child_id: child.id, registerable: afternoon }])
    invoice.opt_regs.create!(child:, registerable: photo)
    invoice.update_columns(in_ss: true, total_cost: invoice.total_cost + photo.cost)

    invoice.reload.recalculate_pricing!

    expect(invoice.reload.opt_regs).to be_empty
    expect(invoice.total_cost).to eq(event.member_prices.courses['1'])
    expect(invoice).to be_in_ss
  end

  it 'retains the existing photo-service behavior for party events' do
    event.update!(early_bird_discount: -500, early_bird_date: Date.new(2020, 1, 1))

    expect(invoice_with_photo([afternoon]).opt_regs.map(&:registerable_id)).to eq([photo.id])
  end
end
