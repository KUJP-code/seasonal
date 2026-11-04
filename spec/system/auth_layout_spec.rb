# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Campaign landing and login layout', :js do
  def viewport(width, height)
    page.driver.browser.execute_cdp('Emulation.setDeviceMetricsOverride',
                                    width:, height:, deviceScaleFactor: 1, mobile: width < 768)
  end

  def expect_uncropped_campaign_and_joined_controls
    page.evaluate_async_script('document.fonts.ready.then(() => arguments[0](true))')
    measurements = page.evaluate_script(<<~JS)
      (() => {
        const image = document.querySelector('#splash-img img');
        const rect = image.getBoundingClientRect();
        const controls = document.querySelector('#action-pane').getBoundingClientRect();
        return {loaded: image.complete && image.naturalWidth > 0,
                ratio: rect.width / rect.height, naturalRatio: image.naturalWidth / image.naturalHeight,
                gap: controls.top - rect.bottom,
                overflow: document.documentElement.scrollWidth - innerWidth,
                imageFit: getComputedStyle(image).objectFit,
                background: getComputedStyle(document.querySelector('#action-pane')).backgroundColor};
      })()
    JS
    expect(measurements).to include(
      'loaded' => true,
      'ratio' => be_within(0.002).of(measurements['naturalRatio']),
      'gap' => be_between(-1, 1),
      'overflow' => be <= 1,
      'imageFit' => 'contain',
      'background' => 'rgb(78, 74, 74)'
    )
  end

  after do
    page.driver.browser.execute_cdp('Emulation.clearDeviceMetricsOverride')
  end

  it 'keeps the landing image complete and controls together on desktop and mobile' do
    [[1440, 900], [1024, 768], [768, 1024], [390, 844], [360, 740]].each do |width, height|
      viewport(width, height)
      visit root_path
      expect_uncropped_campaign_and_joined_controls
      expect(page).to have_link('新規登録', href: new_user_registration_path)
      expect(page).to have_link('ログイン', href: new_user_session_path)
      expect(page).to have_link('申込サイトの使い方はこちら')
    end
  end

  it 'keeps the login form accessible below the image at desktop and mobile sizes' do
    sizes = [[1440, 900], [1024, 768], [768, 1024], [390, 844], [360, 740], [320, 640]]
    sizes.each do |width, height|
      viewport(width, height)
      visit new_user_session_path
      expect_uncropped_campaign_and_joined_controls
      expect(page).to have_field('user_email')
      expect(page).to have_field('user_password', type: 'password')
      expect(page).to have_field('user_remember_me')
      expect(page).to have_link(I18n.t('devise.sessions.new.forgot_password'))
      expect(page).to have_link('新規登録')
      expect(page).to have_no_css('#login h2')
      expect(page.evaluate_script(<<~JS)).to eq([])
        Array.from(document.querySelectorAll('#action-pane .form-check-label, #reset-pass, #action-pane .form-control'))
          .filter(node => {
            const box = node.getBoundingClientRect();
            return node.scrollWidth > node.clientWidth + 1 || box.left < 0 || box.right > innerWidth + 1;
          }).map(node => node.id || node.className)
      JS
    end
  end

  it 'still signs in with the normal customer account' do
    customer = create(:customer)
    viewport(390, 844)
    visit new_user_session_path
    fill_in 'user_email', with: customer.email
    fill_in 'user_password', with: customer.password
    click_on 'ログイン'

    expect(page).to have_link(href: destroy_user_session_path, visible: :all)
  end
end
