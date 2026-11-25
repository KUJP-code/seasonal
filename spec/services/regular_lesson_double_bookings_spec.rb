# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegularLessonDoubleBookings do
  let(:child) { create(:internal_child) }
  let(:event) do
    create(:event, start_date: Date.new(2026, 12, 14), end_date: Date.new(2026, 12, 25))
  end
  # Tuesday 12/15; creating a morning activity also creates its 通常レッスン afternoon.
  let(:morning) do
    create(:time_slot, :morning, event:, start_time: Time.zone.local(2026, 12, 15, 10),
                                 end_time: Time.zone.local(2026, 12, 15, 13))
  end
  let!(:booking) do
    regs = [morning, morning.afternoon_slot].map { { child_id: child.id, registerable: _1 } }
    create(:invoice, event:, child:, slot_regs_attributes: regs)
  end
  let!(:schedule) { create(:regular_schedule, child:, month: Date.new(2026, 12, 1), tuesday: true) }

  it 'lists 通常レッスン booked on a regular weekday' do
    clashes = described_class.new([child.id]).call

    expect(clashes.map { [_1.invoice, _1.dates] }).to eq([[booking, [Date.new(2026, 12, 15)]]])
    expect(PriceChange.double_booking.sole)
      .to have_attributes(invoice: booking, details: '2026-12-15', old_total: booking.total_cost)
  end

  it 'does not list the same dates again once ticked' do
    described_class.new.call
    PriceChange.sole.mark_seen!(create(:admin))

    described_class.new.call

    expect(PriceChange.count).to eq(1)
  end

  it 'removes an unticked entry once the weekday changes' do
    described_class.new.call
    schedule.update!(tuesday: false, wednesday: true)

    expect(described_class.new.call).to be_empty
    expect(PriceChange.count).to eq(0)
  end

  it 'ignores events before monthly weekday pricing and external students' do
    event.update!(start_date: RegularDayRepricing::FIRST_EVENT_DATE - 1.day)
    expect(described_class.new.call).to be_empty

    event.update!(start_date: RegularDayRepricing::FIRST_EVENT_DATE)
    child.update!(category: :external)
    expect(described_class.new.call).to be_empty
  end
end
