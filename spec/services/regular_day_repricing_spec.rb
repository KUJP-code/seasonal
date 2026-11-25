# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegularDayRepricing do
  let(:prices) do
    create(:member_prices, course1: '5500', course3: '', course5: '22000',
                           course10: '40000', course15: '', course20: '',
                           course25: '', course30: '', course35: '', course40: '',
                           course45: '', course50: '', regular_day_afternoon_price: 2700)
  end
  let(:event) do
    create(:event, member_prices: prices,
                   start_date: Date.new(2026, 12, 1), end_date: Date.new(2027, 1, 31))
  end
  let(:child) { create(:internal_child, kindy: false, own_snack: false) }
  let(:january) { Date.new(2027, 1, 1) }

  before do
    create(:regular_schedule, child:, month: Date.new(2026, 12, 1), monday: true, tuesday: true)
  end

  def afternoon(date)
    create(:time_slot, :afternoon, event:,
                                   start_time: date.in_time_zone.change(hour: 13, min: 30),
                                   end_time: date.in_time_zone.change(hour: 18, min: 30))
  end

  def confirmed_booking(*dates)
    attributes = dates.map { |date| { child_id: child.id, registerable: afternoon(date) } }
    create(:invoice, event:, child:, slot_regs_attributes: attributes).tap do |invoice|
      invoice.update!(in_ss: true)
    end
  end

  def upload_january(**)
    create(:regular_schedule, child:, month: january, **)
    described_class.new([child.id], january).call
  end

  it "reprices a confirmed January booking from January's weekdays" do
    # Before January's upload, Mon 4 and Tue 5 fall back to December's Mon/Tue.
    booking = confirmed_booking(Date.new(2027, 1, 4), Date.new(2027, 1, 5), Date.new(2027, 1, 6))
    expect(booking.total_cost).to eq((2700 * 2) + 5500)

    changes = upload_january(wednesday: true)

    expect(booking.reload).to have_attributes(in_ss: true, total_cost: 2700 + (5500 * 2))
    expect(booking.summary).to include('通学日午後コース x 1')
    expect(changes.map { |c| [c.invoice.id, c.old_total, c.new_total] })
      .to eq([[booking.id, 10_900, 13_700]])
  end

  it 'keeps December discounts in a booking spanning both months' do
    booking = confirmed_booking(Date.new(2026, 12, 7), Date.new(2027, 1, 5))
    expect(booking.total_cost).to eq(2700 * 2)

    upload_january(wednesday: true)

    expect(booking.reload.total_cost).to eq(2700 + 5500)
  end

  it 'rebuilds packages when afternoons stop being regular days' do
    booking = confirmed_booking(*(4..8).map { |day| Date.new(2027, 1, day) })
    expect(booking.total_cost).to eq((2700 * 2) + (5500 * 3))

    upload_january

    expect(booking.reload.total_cost).to eq(22_000)
  end

  it 'leaves December-only bookings alone after a January upload' do
    booking = confirmed_booking(Date.new(2026, 12, 7), Date.new(2026, 12, 9))

    expect(upload_january(wednesday: true)).to be_empty
    expect(booking.reload.total_cost).to eq(2700 + 5500)
  end

  it 'never reprices students who are no longer internal' do
    booking = confirmed_booking(Date.new(2026, 12, 7), Date.new(2027, 1, 5))
    child.update!(category: :external)

    expect(upload_january).to be_empty
    expect(booking.reload.total_cost).to eq(2700 * 2)
  end

  it 'lists changed totals for managers and keeps the previous version in the history',
     :versioning do
    booking = confirmed_booking(Date.new(2027, 1, 4), Date.new(2027, 1, 5))

    upload_january(monday: true)

    expect(PriceChange.unseen.sole).to have_attributes(invoice: booking, old_total: 5400,
                                                       new_total: 2700 + 5500,
                                                       attendance_month: january)
    expect(booking.versions.last.reify).to have_attributes(total_cost: 5400, in_ss: true)
  end

  it 'does not list a booking whose total stays the same' do
    confirmed_booking(Date.new(2027, 1, 4), Date.new(2027, 1, 6))

    upload_january(monday: true)

    expect(PriceChange.count).to eq(0)
  end

  it 'never touches events that started before monthly weekday pricing' do
    event.update!(start_date: described_class::FIRST_EVENT_DATE - 1.day)
    booking = confirmed_booking(Date.new(2027, 1, 4))

    expect(upload_january).to be_empty
    expect(booking.reload.total_cost).to eq(2700)
    expect(PriceChange.count).to eq(0)
  end

  context 'with the weekdays from before the upload' do
    def upload_january_after(previous, **)
      create(:regular_schedule, child:, month: january, **)
      described_class.new([child.id], january, previous: { child.id => previous }).call
    end

    it 'reprices bookings where an afternoon changes regular-day status' do
      booking = confirmed_booking(Date.new(2027, 1, 4))

      changes = upload_january_after(nil, wednesday: true)

      expect(changes.map(&:status)).to eq([:repriced])
      expect(booking.reload.total_cost).to eq(5500)
    end

    it 'leaves bookings alone whose afternoons keep their status, even if mispriced' do
      booking = confirmed_booking(Date.new(2027, 1, 6))
      # e.g. pricing rules changed since booking
      booking.update_columns(total_cost: 9999) # rubocop:disable Rails/SkipsModelValidations

      expect(upload_january_after(nil, monday: true)).to be_empty
      expect(booking.reload.total_cost).to eq(9999)
      expect(PriceChange.count).to eq(0)
    end

    it 'still reprices bookings that only have automatic adjustments' do
      booking = confirmed_booking(Date.new(2027, 1, 4))
      booking.adjustments.create!(change: -500, reason: Adjustment::EARLY_BIRD)

      changes = upload_january_after(nil, wednesday: true)

      expect(changes.map(&:status)).to eq([:repriced])
    end

    it 'lists bookings with manual adjustments for review instead of repricing them' do
      booking = confirmed_booking(Date.new(2027, 1, 4))
      create(:adjustment, invoice: booking, change: -100, reason: '通学日調整')
      booking.reload.update!(in_ss: false)
      booking.update!(in_ss: true)
      total = booking.total_cost

      changes = upload_january_after(nil, wednesday: true)

      expect(changes.map(&:status)).to eq([:review])
      expect(booking.reload.total_cost).to eq(total)
      expect(PriceChange.needs_review.sole).to have_attributes(old_total: total,
                                                               new_total: total + 2800)
    end
  end

  it 'does not save during a dry run' do
    booking = confirmed_booking(Date.new(2027, 1, 4))
    create(:regular_schedule, child:, month: january)

    changes = described_class.new([child.id], january).call(apply: false)

    expect(changes.map(&:new_total)).to eq([5500])
    expect(booking.reload.total_cost).to eq(2700)
    expect(PriceChange.count).to eq(0)
  end
end
