# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Photo service on parent bookings', :js do
  include RegistrationFlowHelpers

  let(:parent) { create(:customer) }
  let(:child) { create(:internal_child, parent:, own_snack: false) }
  let(:prices) { create(:member_prices, course1: '5500') }
  let(:event) do
    create(:event, school: child.school, member_prices: prices,
                   start_date: 1.week.from_now.to_date, end_date: 2.weeks.from_now.to_date)
  end
  let!(:photo) { create(:event_option, optionable: event, name: 'Photo service', cost: 1000) }
  let!(:afternoon) { create(:time_slot, :afternoon, event:, snack: true, close_at: 1.week.from_now) }
  let(:morning) { create(:time_slot, :morning, event:, close_at: 1.week.from_now) }

  before do
    sign_in parent
    page.current_window.resize_to(1400, 1000)
  end

  def submit_booking
    click_on I18n.t('invoices.registration_page.price_footer.confirm_invoice')
    expect(page).to have_css('#final_cost', text: cost_text(5725))
    click_on I18n.t('invoices.confirm.confirm_changes')
    expect(page).to have_content(I18n.t('invoices.show.confirm_success'))
  end

  it 'explains why afternoon-only bookings cannot select photos and saves no photo fee' do
    visit new_invoice_path(event_id: event.id, child: child.id, locale: :ja)

    expect(page).to have_field("eopt#{photo.id}", disabled: true)
    expect(page).to have_css('.photoservice-container.photo-service-disabled')
    expect(page).to have_content(I18n.t('photo_service.unavailable'))
    check "a_slot#{afternoon.id}"
    expect(page).to have_css('#total_cost', text: cost_text(5725))
    expect(page).to have_field("eopt#{photo.id}", disabled: true)

    submit_booking

    expect(child.invoices.last.total_cost).to eq(5725)
    expect(child.invoices.last.opt_regs.where(registerable: photo)).to be_empty
  end

  it 'keeps the unavailable banner readable inside a mobile viewport' do
    page.current_window.resize_to(390, 844)
    visit new_invoice_path(event_id: event.id, child: child.id, locale: :ja)

    expect(page).to have_content(I18n.t('photo_service.unavailable'))
    expect(page).to have_field("eopt#{photo.id}", disabled: true)
    bounds = page.evaluate_script(<<~JS)
      (() => {
        const rect = document.querySelector('.photo-service-offer').getBoundingClientRect();
        const banner = document.querySelector('.photoservice-container').getBoundingClientRect();
        const help = document.querySelector('.photo-service-help').getBoundingClientRect();
        return {
          left: rect.left, right: rect.right, viewport: window.innerWidth,
          bannerCenter: (banner.left + banner.right) / 2,
          helpCenter: (help.left + help.right) / 2
        };
      })()
    JS
    expect(bounds['left']).to be >= 0
    expect(bounds['right']).to be <= bounds['viewport']
    expect((bounds['bannerCenter'] - bounds['helpCenter']).abs).to be < 1
  end

  it 'enables photos for a morning and removes the fee again when the last eligible activity is removed' do
    morning
    visit new_invoice_path(event_id: event.id, child: child.id, locale: :ja)
    check "a_slot#{afternoon.id}"
    check "m_slot#{morning.id}"

    expect(page).to have_field("eopt#{photo.id}", disabled: false, checked: false)
    expect(page).to have_content(I18n.t('photo_service.available'))
    check "eopt#{photo.id}"
    expect(page).to have_css('#total_cost', text: cost_text(12_225))

    uncheck "m_slot#{morning.id}"

    expect(page).to have_field("eopt#{photo.id}", disabled: true, checked: false)
    expect(page).to have_css('#total_cost', text: cost_text(5725))
    submit_booking
    expect(child.invoices.last.opt_regs.where(registerable: photo)).to be_empty
  end

  it 'allows and charges photos for a special afternoon on the event booking page' do
    afternoon.update!(category: :special)
    visit event_path(id: event.id, child: child.id, locale: :ja)
    check "a_slot#{afternoon.id}"

    expect(page).to have_field("eopt#{photo.id}", disabled: false)
    check "eopt#{photo.id}"

    expect(page).to have_css('#total_cost', text: cost_text(6725))
    click_on I18n.t('events.show.confirm_invoice')
    expect(page).to have_css('#final_cost', text: cost_text(6725))
    click_on I18n.t('invoices.confirm.confirm_changes')
    expect(page).to have_content(I18n.t('invoices.show.confirm_success'))
    expect(child.invoices.last.opt_regs.where(registerable: photo)).to be_present
  end

  it 'keeps photos available when an eligible activity is already on a confirmed invoice' do
    create(:invoice, child:, event:, in_ss: true,
                     slot_regs_attributes: [{ child_id: child.id, registerable: morning }])
    visit new_invoice_path(event_id: event.id, child: child.id, locale: :ja)

    expect(page).to have_field("eopt#{photo.id}", disabled: false)
    expect(page).not_to have_css('.photoservice-container.photo-service-disabled')
  end

  it 'explains and excludes a stale photo fee on an existing confirmed afternoon-only booking' do
    invoice = create(:invoice, child:, event:,
                     slot_regs_attributes: [{ child_id: child.id, registerable: afternoon }])
    invoice.opt_regs.create!(child:, registerable: photo)
    invoice.update_columns(in_ss: true, total_cost: 6725)

    visit new_invoice_path(event_id: event.id, child: child.id, locale: :ja)

    expect(page).to have_field("eopt#{photo.id}", disabled: true, checked: false)
    expect(page).to have_content(I18n.t('photo_service.unavailable'))
    expect(page).to have_css('#total_cost', text: cost_text(5725))
    expect(invoice.reload.total_cost).to eq(6725)
  end

  it 'keeps a valid confirmed photo selection visible and locked' do
    invoice = create(:invoice, child:, event:,
                     slot_regs_attributes: [{ child_id: child.id, registerable: morning }],
                     opt_regs_attributes: [{ child_id: child.id, registerable_id: photo.id,
                                             registerable_type: 'Option' }])
    invoice.update!(in_ss: true)

    visit new_invoice_path(event_id: event.id, child: child.id, locale: :ja)

    expect(page).to have_field("eopt#{photo.id}", disabled: true, checked: true)
    expect(page).to have_content(I18n.t('photo_service.confirmed'))
    expect(page).to have_css('#total_cost', text: /合計（税込）\s*:\s*6,500円/)
  end

  it 'inherits family photos when an afternoon-only sibling later adds a morning' do
    sibling = create(:internal_child, parent:)
    sibling_morning = create(:time_slot, :morning, event:, close_at: 1.week.from_now)
    create(:invoice, child: sibling, event:,
                     slot_regs_attributes: [{ child_id: sibling.id, registerable: sibling_morning }],
                     opt_regs_attributes: [{ child_id: sibling.id, registerable_id: photo.id,
                                             registerable_type: 'Option' }])
    morning
    create(:invoice, child:, event:,
                     slot_regs_attributes: [{ child_id: child.id, registerable: afternoon }])

    visit new_invoice_path(event_id: event.id, child: child.id, locale: :ja)
    expect(page).to have_field("eopt#{photo.id}", disabled: true, checked: false)

    check "m_slot#{morning.id}"

    expect(page).to have_field("eopt#{photo.id}", disabled: false, checked: true)
    expect(page).to have_css('#total_cost', text: cost_text(12_225))

    uncheck "m_slot#{morning.id}"
    check "m_slot#{morning.id}"
    expect(page).to have_field("eopt#{photo.id}", disabled: false, checked: true)
    expect(page).to have_css('#total_cost', text: cost_text(12_225))

    click_on I18n.t('invoices.registration_page.price_footer.confirm_invoice')
    expect(page).to have_css('#final_cost', text: cost_text(12_225))
    click_on I18n.t('invoices.confirm.confirm_changes')
    expect(page).to have_content(I18n.t('invoices.show.confirm_success'))
    expect(child.invoices.last.opt_regs.where(registerable: photo)).to be_present
    expect(sibling.invoices.last.reload.opt_regs.where(registerable: photo)).to be_present
  end

  it 'warns before opting the family out and preserves that choice through retoggling and save' do
    sibling = create(:internal_child, parent:)
    sibling_morning = create(:time_slot, :morning, event:, close_at: 1.week.from_now)
    create(:invoice, child: sibling, event:,
                     slot_regs_attributes: [{ child_id: sibling.id, registerable: sibling_morning }],
                     opt_regs_attributes: [{ child_id: sibling.id, registerable_id: photo.id,
                                             registerable_type: 'Option' }])
    morning
    visit new_invoice_path(event_id: event.id, child: child.id, locale: :ja)
    check "m_slot#{morning.id}"
    expect(page).to have_field("eopt#{photo.id}", checked: true)

    dismiss_confirm(I18n.t('photo_service.sibling_removal_warning')) { uncheck "eopt#{photo.id}" }
    expect(page).to have_field("eopt#{photo.id}", checked: true)
    accept_confirm(I18n.t('photo_service.sibling_removal_warning')) { uncheck "eopt#{photo.id}" }
    expect(page).to have_field("eopt#{photo.id}", checked: false)
    expect(page).to have_css('#total_cost', text: cost_text(5500))
    expect(find('h2[data-price-target="eventCost"]').text).to include('11,000円')

    uncheck "m_slot#{morning.id}"
    check "m_slot#{morning.id}"
    expect(page).to have_field("eopt#{photo.id}", checked: false)

    click_on I18n.t('invoices.registration_page.price_footer.confirm_invoice')
    expect(page).to have_css('#final_cost', text: cost_text(5500))
    click_on I18n.t('invoices.confirm.confirm_changes')
    expect(page).to have_content(I18n.t('invoices.show.confirm_success'))
    expect(child.invoices.last.opt_regs.where(registerable: photo)).to be_empty
    expect(sibling.invoices.last.reload.opt_regs.where(registerable: photo)).to be_empty
  end
end
