# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Regular-day afternoon booking prices', :js do
  include RegistrationFlowHelpers

  let(:parent) { create(:customer) }
  let(:child) { create(:internal_child, parent:, own_snack: false) }
  let(:prices) do
    create(:member_prices, course1: '5500', course3: '', course5: '22000',
                           course10: '', course15: '', course20: '', course25: '',
                           course30: '', course35: '', course40: '', course45: '',
                           course50: '', regular_day_afternoon_price: 2700)
  end
  let(:event) do
    create(:event, school: child.school, member_prices: prices,
                   start_date: Date.new(2026, 12, 1), end_date: Date.new(2026, 12, 31))
  end

  before do
    create(:regular_schedule, child:, month: Date.new(2026, 12, 1), monday: true, tuesday: true)
    sign_in parent
    page.current_window.resize_to(1400, 1000)
  end

  def afternoon(day, **)
    create(:time_slot, :afternoon, event:, name: "December #{day}", snack: true,
                                   close_at: Time.zone.local(2026, 12, 1),
                                   start_time: Time.zone.local(2026, 12, day, 13, 30),
                                   end_time: Time.zone.local(2026, 12, day, 18, 30), **)
  end

  it 'keeps the live total, confirmation preview and saved invoice at 8425 yen' do
    monday = afternoon(7)
    wednesday = afternoon(9)

    visit new_invoice_path(event_id: event.id, child: child.id, locale: :ja)
    check "a_slot#{monday.id}"
    expect(find_by_id('total_cost').text).to eq(cost_text(2700))
    check "a_slot#{wednesday.id}"
    expect(find_by_id('total_cost').text).to eq(cost_text(8425))
    uncheck "a_slot#{monday.id}"
    expect(find_by_id('total_cost').text).to eq(cost_text(5725))
    check "a_slot#{monday.id}"
    expect(find_by_id('total_cost').text).to eq(cost_text(8425))

    click_on I18n.t('invoices.registration_page.price_footer.confirm_invoice')
    expect(page).to have_content(I18n.t('invoices.confirm.not_done'))
    expect(page).to have_css('#final_cost', text: cost_text(8425))
    click_on I18n.t('invoices.confirm.confirm_changes')
    expect(page).to have_content(I18n.t('invoices.show.confirm_success'))
    expect(child.invoices.last.total_cost).to eq(8425)
    expect(child.invoices.last.summary).to include('午後コースおやつ代 x 1: 225円')
  end

  it 'keeps five sessions in the normal package, including snacks, when the price is blank' do
    prices.update!(regular_day_afternoon_price: nil)
    slots = [7, 8, 9, 10, 11].map { |day| afternoon(day) }

    visit new_invoice_path(event_id: event.id, child: child.id, locale: :ja)
    slots.each { |slot| check "a_slot#{slot.id}" }

    expect(find_by_id('total_cost').text).to eq(cost_text(23_125))
  end

  it 'keeps external students on normal pricing even when their price list has a regular-day rate' do
    child.update!(category: :external)
    event.update!(non_member_prices: prices)
    slots = [7, 8, 9, 10, 11].map { |day| afternoon(day) }

    visit new_invoice_path(event_id: event.id, child: child.id, locale: :ja)
    expect(page).to have_no_css('.regular-day-price')
    expect(page).to have_no_content(I18n.t('regular_day_pricing.explanation'))
    slots.each { |slot| check "a_slot#{slot.id}" }
    expect(find_by_id('total_cost').text).to eq(cost_text(23_125))

    click_on I18n.t('invoices.registration_page.price_footer.confirm_invoice')
    expect(page).to have_css('#final_cost', text: cost_text(23_125))
    click_on I18n.t('invoices.confirm.confirm_changes')
    expect(page).to have_content(I18n.t('invoices.show.confirm_success'))
    expect(child.invoices.last.total_cost).to eq(23_125)
  end

  it 'excludes discounted sessions from packages while retaining normal snack charges' do
    normal = [9, 10, 11, 16, 17, 18].map { |day| afternoon(day) }
    regular = [7, 8, 14, 15].map { |day| afternoon(day) }

    visit new_invoice_path(event_id: event.id, child: child.id, locale: :ja)
    (normal + regular).each { |slot| check "a_slot#{slot.id}" }

    expect(find_by_id('total_cost').text).to eq(cost_text(38_300 + (225 * 6)))
  end

  it 'keeps special prices and the correct initial snack count on an existing invoice' do
    monday = afternoon(7)
    special = afternoon(8, category: :special)
    create(:invoice, event:, child:,
                     slot_regs_attributes: [{ child_id: child.id, registerable: monday }])

    visit new_invoice_path(event_id: event.id, child: child.id, locale: :ja)
    check "a_slot#{special.id}"
    expect(find_by_id('total_cost').text).to eq(cost_text(8425))
    find('summary', text: I18n.t('invoices.new.registered_slots')).click
    uncheck "a_slot#{monday.id}"
    expect(find_by_id('total_cost').text).to eq(cost_text(5725))
    check "a_slot#{monday.id}"
    expect(find_by_id('total_cost').text).to eq(cost_text(8425))
  end

  it 'uses the same regular-day prices on the event booking page' do
    monday = afternoon(7)
    wednesday = afternoon(9)

    visit event_path(id: event.id, child: child.id, locale: :ja)
    check "a_slot#{monday.id}"
    check "a_slot#{wednesday.id}"

    expect(find_by_id('total_cost').text).to eq(cost_text(8425))
  end

  it 'uses December weekdays for January labels, live prices and the confirmation preview' do
    event.update!(end_date: Date.new(2027, 1, 31))
    january = create(:time_slot, :afternoon, event:, name: 'January Monday', snack: true,
                                             close_at: Time.zone.local(2027, 1, 1),
                                             start_time: Time.zone.local(2027, 1, 4, 13, 30),
                                             end_time: Time.zone.local(2027, 1, 4, 18, 30))

    visit new_invoice_path(event_id: event.id, child: child.id, locale: :ja)
    expect(page).to have_css('.regular-school-days', text: '12月：月・火　1月：月・火', exact_text: true)
    check "a_slot#{january.id}"
    expect(find_by_id('total_cost').text).to eq(cost_text(2700))
    click_on I18n.t('invoices.registration_page.price_footer.confirm_invoice')
    expect(page).to have_css('#final_cost', text: cost_text(2700))
    expect(page).to have_no_content('午後コースおやつ代 x')
  end
end
