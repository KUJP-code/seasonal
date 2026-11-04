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

  it 'applies the regular-day offer to afternoon activities and excludes regular lessons' do
    morning = create(:time_slot, :morning, event:, close_at: Time.zone.local(2026, 12, 1),
                                           start_time: Time.zone.local(2026, 12, 7, 10),
                                           end_time: Time.zone.local(2026, 12, 7, 13))
    lesson = morning.afternoon_slot
    activity = afternoon(8)

    visit new_invoice_path(event_id: event.id, child: child.id, locale: :ja)
    lesson_card = find_by_id("a_slot#{lesson.id}")
                  .find(:xpath, 'ancestor::div[contains(@class,"afternoon")]')
    within(lesson_card) do
      expect(page).to have_content('午後（通常レッスン）')
      expect(page).to have_no_css('.regular-day-price')
    end
    check "a_slot#{lesson.id}"
    expect(find_by_id('total_cost').text).to eq(cost_text(5725))
    check "a_slot#{activity.id}"
    expect(find_by_id('total_cost').text).to eq(cost_text(8425))

    click_on I18n.t('invoices.registration_page.price_footer.confirm_invoice')
    expect(page).to have_css('#final_cost', text: cost_text(8425))
    click_on I18n.t('invoices.confirm.confirm_changes')
    expect(page).to have_content(I18n.t('invoices.show.confirm_success'))
    invoice = child.invoices.last
    expect(invoice.total_cost).to eq(8425)
    expect(invoice.summary).to include('通学日午後コース x 1: 2,700円', '午後コースおやつ代 x 1: 225円')
  end

  it 'waives own-snack fees through booking and labels confirmed activities correctly' do
    child.update!(own_snack: true)
    slot = afternoon(9)

    visit new_invoice_path(event_id: event.id, child: child.id, locale: :ja)
    check "a_slot#{slot.id}"
    expect(page).to have_content('おやつ持参（料金なし）')
    expect(find_by_id('total_cost').text).to eq(cost_text(5500))
    uncheck "a_slot#{slot.id}"
    expect(find_by_id('total_cost').text).to eq(cost_text(0))
    check "a_slot#{slot.id}"
    expect(find_by_id('total_cost').text).to eq(cost_text(5500))

    click_on I18n.t('invoices.registration_page.price_footer.confirm_invoice')
    expect(page).to have_css('#final_cost', text: cost_text(5500))
    expect(page).to have_content('おやつ代なし（おやつ持参）', count: 1)
    expect(page).to have_no_content('午後コースおやつ代 x')
    click_on I18n.t('invoices.confirm.confirm_changes')
    expect(page).to have_content(I18n.t('invoices.show.confirm_success'))
    invoice = child.invoices.last
    expect(invoice.total_cost).to eq(5500)
    expect(invoice.summary).not_to include('午後コースおやつ代 x')
    expect(invoice.summary.scan('おやつ代なし（おやつ持参）').size).to eq(1)

    invoice.update!(in_ss: true)
    visit new_invoice_path(event_id: event.id, child: child.id, locale: :ja)
    find('summary', text: I18n.t('invoices.new.registered_slots')).click
    expect(page).to have_content('おやつ持参（料金なし）')
    expect(page).to have_no_content('午後コースおやつ代: ◯')
    expect(find_by_id('total_cost').text).to match(/合計（税込）\s*:\s*5,500円/)
  end

  it 'also waives own-snack fees for external students and special activities on the event page' do
    child.update!(category: :external, own_snack: true)
    event.update!(non_member_prices: prices)
    normal = afternoon(9)
    special = afternoon(10, category: :special)

    visit event_path(id: event.id, child: child.id, locale: :ja)
    check "a_slot#{normal.id}"
    check "a_slot#{special.id}"

    expect(find_by_id('total_cost').text).to eq(cost_text(11_000))
    expect(page).to have_content('おやつ持参（料金なし）', count: 2)
  end

  it 'keeps external students on normal pricing when their price list has a regular-day rate' do
    child.update!(category: :external)
    event.update!(non_member_prices: prices)
    slots = [7, 8, 9, 10, 11].map { |day| afternoon(day) }

    visit new_invoice_path(event_id: event.id, child: child.id, locale: :ja)
    expect(page).to have_no_css('.regular-day-price')
    expect(page).to have_no_content(I18n.t('regular_day_pricing.explanation'))
    slots.each do |slot|
      scroll_to(find_by_id("a_slot#{slot.id}"), align: :center)
      check "a_slot#{slot.id}"
    end
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
    expect(page).to have_no_css('.regular-school-days, .regular-day, .afternoon .text-bg-danger')
    expect(page).to have_no_content('12月：月・火')
    expect(page).to have_no_content('1月：月・火')
    expect(page).to have_no_content('ご通学日')
    check "a_slot#{january.id}"
    expect(find_by_id('total_cost').text).to eq(cost_text(2700))
    click_on I18n.t('invoices.registration_page.price_footer.confirm_invoice')
    expect(page).to have_css('#final_cost', text: cost_text(2700))
    expect(page).to have_no_content('午後コースおやつ代 x')
  end
end
