# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invoice do
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

  before do
    create(:regular_schedule, child:, month: Date.new(2026, 12, 1),
                              monday: true, tuesday: true)
  end

  def afternoon(day, **)
    create(:time_slot, :afternoon, event:,
                                   start_time: Time.zone.local(2026, 12, day, 13, 30),
                                   end_time: Time.zone.local(2026, 12, day, 18, 30),
                                   **)
  end

  def invoice_for(slots)
    attributes = slots.map { |slot| { child_id: child.id, registerable: slot } }
    create(:invoice, event:, child:, slot_regs_attributes: attributes)
  end

  [[2, 1, 13_700], [3, 2, 21_900], [6, 4, 38_300]].each do |normal, regular, total|
    it "prices #{normal + regular} sessions with #{regular} regular afternoons at #{total} yen" do
      slots = (9..11).to_a.concat((16..18).to_a).first(normal).map { |day| afternoon(day) } +
              (7..8).to_a.concat((14..15).to_a).first(regular).map { |day| afternoon(day) }

      invoice = invoice_for(slots)

      expect(invoice.reload.total_cost).to eq(total)
      expect(invoice.summary).to include("通学日午後コース x #{regular}")
    end
  end

  it 'charges only the non-regular Wednesday snack in the Monday/Wednesday example' do
    invoice = invoice_for([afternoon(7, snack: true), afternoon(9, snack: true)])

    expect(invoice.total_cost).to eq(8425)
    expect(invoice.summary).to include('午後コースおやつ代 x 1: 225円')
    expect(invoice.generate_data).to include(snack_count: 1, snack_cost: 225)
  end

  it 'keeps all sessions in normal packages and charges all snacks when the price is blank' do
    prices.update!(regular_day_afternoon_price: '')
    slots = [7, 8, 9, 10, 11].map { |day| afternoon(day, snack: true) }

    invoice = invoice_for(slots)

    expect(invoice.total_cost).to eq(22_000 + (225 * 5))
    expect(invoice.summary).not_to include('通学日午後コース')
  end

  it 'does not carry the afternoon price over to an event using a different price list' do
    other_prices = create(:member_prices, course1: '5500')
    event.update!(member_prices: other_prices)

    expect(invoice_for([afternoon(7, snack: true)]).total_cost).to eq(5725)
  end

  it 'uses a configured amount rather than a fixed 2700 yen rate' do
    prices.update!(regular_day_afternoon_price: 3100)

    expect(invoice_for([afternoon(7, snack: true)]).total_cost).to eq(3100)
  end

  it 'allows an explicit zero price while still excluding the afternoon and its snack' do
    prices.update!(regular_day_afternoon_price: 0)

    expect(invoice_for([afternoon(7, snack: true)]).total_cost).to eq(0)
  end

  it 'does not apply to mornings on regular lesson days' do
    morning = create(:time_slot, :morning, event:,
                                           start_time: Time.zone.local(2026, 12, 7, 10),
                                           end_time: Time.zone.local(2026, 12, 7, 13))

    expect(invoice_for([morning]).total_cost).to eq(5500)
  end

  %i[special party].each do |category|
    it "keeps normal pricing and snack fees for #{category} afternoons" do
      expect(invoice_for([afternoon(7, category:, snack: true)]).total_cost).to eq(5725)
    end
  end

  it 'does not apply seasonal regular-day pricing to a party event' do
    event.update!(early_bird_discount: -500, early_bird_date: Date.new(2020, 1, 1))

    expect(invoice_for([afternoon(7, snack: true)]).total_cost).to eq(5725)
  end

  it 'uses December weekdays to discount January afternoons and waive their snacks' do
    slot = create(:time_slot, :afternoon, event:, snack: true,
                                          start_time: Time.zone.local(2027, 1, 4, 13, 30),
                                          end_time: Time.zone.local(2027, 1, 4, 18, 30))

    expect(invoice_for([slot]).total_cost).to eq(2700)
  end

  it 'keeps normal prices and snack fees when the latest schedule is over five months old' do
    child.regular_schedules.destroy_all
    child.regular_schedules.create!(month: Date.new(2026, 6, 1), monday: true)

    expect(invoice_for([afternoon(7, snack: true)]).total_cost).to eq(5725)
  end

  it 'does not discount future afternoons after an explicit no-days schedule' do
    child.regular_schedules.create!(month: Date.new(2027, 1, 1))
    slot = create(:time_slot, :afternoon, event:, snack: true,
                                          start_time: Time.zone.local(2027, 1, 4, 13, 30),
                                          end_time: Time.zone.local(2027, 1, 4, 18, 30))

    expect(invoice_for([slot]).total_cost).to eq(5725)
  end

  it 'uses each activity month when the regular weekdays change across months' do
    create(:regular_schedule, child:, month: Date.new(2027, 1, 1), wednesday: true)
    january = create(:time_slot, :afternoon, event:, snack: true,
                                             start_time: Time.zone.local(2027, 1, 6, 13, 30),
                                             end_time: Time.zone.local(2027, 1, 6, 18, 30))

    expect(invoice_for([afternoon(9, snack: true), january]).total_cost).to eq(8425)
  end

  %i[external reservation unknown].each do |category|
    it "keeps normal packages and snack fees for #{category} students with regular weekdays" do
      child.update!(category:)
      event.update!(non_member_prices: prices)
      slots = [7, 8, 9, 10, 11].map { |day| afternoon(day, snack: true) }

      invoice = invoice_for(slots)

      expect(invoice.total_cost).to eq(22_000 + (225 * 5))
      expect(invoice.summary).not_to include('通学日午後コース')
      expect(event.regular_day_afternoon_price_for(child)).to be_nil
      expect(event.regular_day_slot_prices_for(child)).to eq({})
    end
  end

  it 'does not fall back to the member afternoon price when the non-member price is blank' do
    child.update!(category: :external)

    expect(invoice_for([afternoon(7, snack: true)]).total_cost)
      .to eq(event.non_member_prices.courses['1'] + 225)
  end

  it 'preserves activity surcharges and selected options on a regular-day afternoon' do
    slot = afternoon(7, snack: true, int_modifier: 300)
    meal = slot.options.meal.first
    invoice = invoice_for([slot])
    invoice.opt_regs.create!(child:, registerable: meal)
    invoice.reload.save!

    expect(invoice.total_cost).to eq(2700 + 300 + meal.cost)
  end

  it 'keeps the own-snack exemption on non-regular afternoons' do
    child.update!(own_snack: true)

    expect(invoice_for([afternoon(7, snack: true),
                        afternoon(9, snack: true)]).total_cost).to eq(8200)
  end

  it 'preserves separate normal pricing batches when regular-day afternoons are added later' do
    invoice = invoice_for([9, 10, 11, 16].map { |day| afternoon(day) })
    new_slots = [afternoon(17), afternoon(7, snack: true)]
    attributes = new_slots.map { |slot| { child_id: child.id, registerable: slot } }
    invoice.update!(slot_regs_attributes: attributes)

    expect(invoice.reload.total_cost).to eq((5500 * 5) + 2700)
    expect(invoice.slot_regs.pluck(:pricing_batch).uniq).to eq([1, 2])
  end

  it 'ignores removed regular-day afternoons when recalculating an invoice' do
    regular_slot = afternoon(7, snack: true)
    invoice = invoice_for([regular_slot, afternoon(9, snack: true)])
    regular_reg = invoice.slot_regs.find_by!(registerable_id: regular_slot.id)
    invoice.update!(slot_regs_attributes: [{ id: regular_reg.id, _destroy: '1' }])

    expect(invoice.reload.total_cost).to eq(5725)
  end

  it 'does not reprice saved locked invoices when the rate or attendance schedule changes' do
    invoice = invoice_for([afternoon(7, snack: true)])
    invoice.update!(in_ss: true)
    original = invoice.attributes.slice('total_cost', 'summary')
    prices.update!(regular_day_afternoon_price: nil)
    child.regular_schedules.first.update!(monday: false)
    invoice.reload.save!

    expect(invoice.reload.attributes.slice('total_cost', 'summary')).to eq(original)
  end
end
