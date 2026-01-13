# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invoice do
  let(:event) do
    create(:event,
           start_date: Date.new(2026, 8, 1),
           end_date: Date.new(2026, 8, 2),
           early_bird_date: Date.new(2026, 7, 1))
  end
  let(:photo_option) { create(:event_option, optionable: event, category: :event) }
  let(:time_slot) { create(:time_slot, event:) }
  let(:parent) { create(:user) }
  let(:child) { create(:child, parent:) }
  let(:sibling) { create(:child, parent:) }

  def add_slot(invoice, child_record)
    create(:slot_reg, child: child_record, invoice:, registerable: time_slot)
  end

  def add_photo(invoice, child_record)
    create(:event_opt_reg, child: child_record, invoice:, registerable: photo_option)
    invoice.reload
  end

  it 'adds photo service to siblings with registrations for 2026+ events' do
    invoice = create(:invoice, child:, event:)
    sibling_invoice = create(:invoice, child: sibling, event:)
    add_slot(invoice, child)
    add_slot(sibling_invoice, sibling)

    add_photo(invoice, child)
    invoice.sync_photo_service_with_siblings!

    expect(sibling_invoice.opt_regs.where(registerable: photo_option)).to be_present
  end

  it 'removes photo service from siblings with registrations for 2026+ events' do
    invoice = create(:invoice, child:, event:)
    sibling_invoice = create(:invoice, child: sibling, event:)
    add_slot(invoice, child)
    add_slot(sibling_invoice, sibling)
    add_photo(invoice, child)
    add_photo(sibling_invoice, sibling)

    invoice.opt_regs.where(registerable: photo_option).destroy_all
    invoice.sync_photo_service_with_siblings!

    expect(sibling_invoice.opt_regs.where(registerable: photo_option)).to be_empty
  end

  it 'does not sync photo service for events before 2026' do
    event_2025 = create(:event,
                        start_date: Date.new(2025, 8, 1),
                        end_date: Date.new(2025, 8, 2),
                        early_bird_date: Date.new(2025, 7, 1))
    photo_2025 = create(:event_option, optionable: event_2025, category: :event)
    time_slot_2025 = create(:time_slot, event: event_2025)
    invoice = create(:invoice, child:, event: event_2025)
    sibling_invoice = create(:invoice, child: sibling, event: event_2025)
    create(:slot_reg, child:, invoice:, registerable: time_slot_2025)
    create(:slot_reg, child: sibling, invoice: sibling_invoice, registerable: time_slot_2025)
    create(:event_opt_reg, child:, invoice:, registerable: photo_2025)
    invoice.reload

    invoice.sync_photo_service_with_siblings!

    expect(sibling_invoice.opt_regs.where(registerable: photo_2025)).to be_empty
  end

  it 'does not sync photo service across different events' do
    other_event = create(:event,
                         start_date: Date.new(2026, 9, 1),
                         end_date: Date.new(2026, 9, 2),
                         early_bird_date: Date.new(2026, 8, 1))
    other_photo = create(:event_option, optionable: other_event, category: :event)
    other_slot = create(:time_slot, event: other_event)
    invoice = create(:invoice, child:, event:)
    sibling_invoice = create(:invoice, child: sibling, event: other_event)
    add_slot(invoice, child)
    create(:slot_reg, child: sibling, invoice: sibling_invoice, registerable: other_slot)

    add_photo(invoice, child)
    invoice.sync_photo_service_with_siblings!

    expect(sibling_invoice.opt_regs.where(registerable: other_photo)).to be_empty
  end

  it 'does not sync photo service when siblings lack time slots' do
    invoice = create(:invoice, child:, event:)
    sibling_invoice = create(:invoice, child: sibling, event:)
    add_slot(invoice, child)

    add_photo(invoice, child)
    invoice.sync_photo_service_with_siblings!

    expect(sibling_invoice.opt_regs.where(registerable: photo_option)).to be_empty
  end

  it 'removes photo service from confirmed sibling invoices' do
    invoice = create(:invoice, child:, event:)
    sibling_invoice = create(:invoice, child: sibling, event:, in_ss: true)
    add_slot(invoice, child)
    add_slot(sibling_invoice, sibling)
    add_photo(invoice, child)
    add_photo(sibling_invoice, sibling)

    invoice.opt_regs.where(registerable: photo_option).destroy_all
    invoice.sync_photo_service_with_siblings!

    expect(sibling_invoice.reload.opt_regs.where(registerable: photo_option)).to be_empty
  end

  it 'adds photo service to confirmed sibling invoices' do
    invoice = create(:invoice, child:, event:)
    sibling_invoice = create(:invoice, child: sibling, event:, in_ss: true)
    add_slot(invoice, child)
    add_slot(sibling_invoice, sibling)

    add_photo(invoice, child)
    invoice.sync_photo_service_with_siblings!

    expect(sibling_invoice.reload.opt_regs.where(registerable: photo_option)).to be_present
  end
end
