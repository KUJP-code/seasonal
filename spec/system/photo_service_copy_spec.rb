# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Seasonal photo-service wording', :js do
  include ActiveSupport::Testing::TimeHelpers

  let(:copy_date) { Time.zone.local(2026, 11, 2, 12) }
  let(:child) do
    create(:internal_child, parent: create(:customer), school: create(:school, name: '蒲田駅前'))
  end
  let(:event) do
    create(:event, school: child.school, name: 'ウインタースクール 2026',
                   start_date: Date.new(2026, 12, 14), end_date: Date.new(2027, 2, 8))
  end
  let!(:photo) { create(:event_option, optionable: event, cost: 1100) }
  let!(:morning) do
    create(:time_slot, :morning, event:, close_at: Time.zone.local(2027, 2, 8),
                                 start_time: Time.zone.local(2026, 12, 25, 10),
                                 end_time: Time.zone.local(2026, 12, 25, 13))
  end

  prepend_before do
    travel_to(copy_date)
  end

  before do
    sign_in child.parent
    page.current_window.resize_to(1400, 1000)
  end

  it 'shows the exact requested wording before and after selecting a program' do
    visit new_invoice_path(event_id: event.id, child: child.id, locale: :ja)

    expect(page).to have_content('※12/25(金)～1/7(木)の午前プログラムを選択するとお申込みできます。')
    expect(page).to have_content('※ごきょうだいの場合は全員分のお申込みが必要となります。')
    expect(page).to have_field("eopt#{photo.id}", disabled: true)

    check "m_slot#{morning.id}"

    expect(page).to have_content('※12/25(金)～1/7(木)の午前プログラムのみのサービスです。')
    expect(page).to have_field("eopt#{photo.id}", disabled: false, checked: false)
  end

  it 'keeps the complete wording and footer compact at narrow mobile widths' do
    [360, 390].each do |width|
      page.driver.browser.execute_cdp('Emulation.setDeviceMetricsOverride',
                                      width:, height: 844, deviceScaleFactor: 1, mobile: true)
      visit new_invoice_path(event_id: event.id, child: child.id, locale: :ja)

      expect(page).to have_content('※12/25(金)～1/7(木)の午前プログラムを選択するとお申込みできます。')
      expect(page).to have_content('※ごきょうだいの場合は全員分のお申込みが必要となります。')
      page.execute_script("document.querySelector('#price-bar').scrollIntoView({block: 'end'})")
      bounds = page.evaluate_script(<<~JS)
        (() => {
          const footer = document.querySelector('#price-bar').getBoundingClientRect();
          const help = document.querySelector('.photo-service-help').getBoundingClientRect();
          return {footerHeight: footer.height, helpHeight: help.height,
                  left: footer.left, right: footer.right, viewport: window.innerWidth};
        })()
      JS
      expect(bounds['viewport']).to eq(width)
      expect(bounds['left']).to be >= 0
      expect(bounds['right']).to be <= width
      expect(bounds['footerHeight']).to be <= 200
      expect(bounds['helpHeight']).to be <= 75
    end
  ensure
    page.driver.browser.execute_cdp('Emulation.clearDeviceMetricsOverride')
  end

  context 'when January 8 begins in Japan' do
    let(:copy_date) { Time.zone.local(2027, 1, 8) }

    it 'automatically displays the general wording again' do
      visit new_invoice_path(event_id: event.id, child: child.id, locale: :ja)

      expect(page).to have_content(I18n.t('photo_service.unavailable'))
      expect(page).to have_content(I18n.t('photo_service.siblings_notice'))
      expect(page).to have_no_content('12/25(金)～1/7(木)')
    end
  end
end
