# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Asset upload queue', :js do
  before do
    sign_in create(:admin)
    page.current_window.resize_to(1400, 1000)
  end

  it 'uploads twelve PNGs exceeding 10 MB in total as individual requests' do
    request_sizes = []
    notification = 'process_action.action_controller'
    subscriber = ActiveSupport::Notifications.subscribe(notification) do |event|
      payload = event.payload
      next unless payload[:controller] == 'UploadsController' && payload[:action] == 'create'

      request_sizes << payload[:params]['uploads'].size
    end

    Dir.mktmpdir('seasonal-asset-batch') do |directory|
      paths = Array.new(12) do |index|
        path = File.join(directory, "activity-#{index}.png")
        FileUtils.cp(Rails.root.join('app/assets/images/2026-science-4th.png'), path)
        path
      end
      expect(paths.sum { |path| File.size(path) }).to be > 10.megabytes

      visit new_upload_path
      attach_file 'Uploads', paths
      select 'Time Slots', from: 'Folder'
      fill_in 'Subfolder', with: 'Winter 2026'
      click_on 'Upload', exact: true

      expect(page).to have_content('12 of 12 images uploaded.', wait: 20)
      expect(ActiveStorage::Blob.count).to eq(12)
      expect(request_sizes).to eq(Array.new(12, 1))
      expect(ActiveStorage::Blob.pluck(:key)).to all(start_with('test/time_slots/winter_2026/'))
    end
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end

  it 'shows a failed image and retries it without reuploading successful images' do
    service = ActiveStorage::Blob.service
    attempts = 0
    allow(service).to receive(:upload).and_wrap_original do |original, key, *args, **kwargs|
      if key.include?('favicon.svg')
        attempts += 1
        raise IOError, 'Storage unavailable' if attempts == 1
      end
      original.call(key, *args, **kwargs)
    end

    visit new_upload_path
    attach_file 'Uploads', [Rails.root.join('app/assets/images/favicon.svg'),
                            Rails.root.join('app/assets/images/logo.svg')]
    click_on 'Upload', exact: true

    expect(page).to have_content('1 of 2 images uploaded. 1 failed; see details below.')
    expect(page).to have_content('favicon.svg — Could not save this image. Retry the upload.')
    expect(ActiveStorage::Blob.count).to eq(1)

    click_on 'Retry failed uploads'

    expect(page).to have_content('2 of 2 images uploaded.')
    expect(page).to have_no_button('Retry failed uploads')
    expect(ActiveStorage::Blob.count).to eq(2)
    expect(attempts).to eq(2)
  end

  it 'shows an oversize error before sending the file to the server' do
    visit new_upload_path
    page.execute_script(<<~JS)
      document.querySelector('[data-controller="asset-upload"]')
        .setAttribute('data-asset-upload-max-size-value', '1024');
    JS
    attach_file 'Uploads', Rails.root.join('app/assets/images/logo.svg')
    click_on 'Upload', exact: true

    expect(page).to have_content('logo.svg — Exceeds 9 MB.')
    expect(page).to have_content('0 of 1 images uploaded. 1 failed; see details below.')
    expect(ActiveStorage::Blob.count).to eq(0)
  end

  it 'shows proxy size and gateway errors even when the server returns HTML' do
    visit new_upload_path
    page.execute_script(<<~JS)
      window.originalAssetUploadSend = XMLHttpRequest.prototype.send;
      XMLHttpRequest.prototype.send = function(body) {
        const status = body.get('uploads[]').name === 'favicon.svg' ? 413 : 502;
        Object.defineProperties(this, {
          status: { value: status },
          responseText: { value: '<html>Proxy error</html>' }
        });
        setTimeout(() => this.onload(), 0);
      };
    JS
    attach_file 'Uploads', [Rails.root.join('app/assets/images/favicon.svg'),
                            Rails.root.join('app/assets/images/logo.svg')]
    click_on 'Upload', exact: true

    expect(page).to have_content('favicon.svg — Server rejected the image size.')
    expect(page).to have_content('logo.svg — Upload was not confirmed (HTTP 502).')
    expect(page).to have_content('0 of 2 images uploaded. 2 failed; see details below.')
    expect(ActiveStorage::Blob.count).to eq(0)

    page.execute_script('XMLHttpRequest.prototype.send = window.originalAssetUploadSend;')
    click_on 'Retry failed uploads'

    expect(page).to have_content('1 of 2 images uploaded. 1 failed; see details below.')
    expect(ActiveStorage::Blob.pluck(:filename)).to eq(['logo.svg'])
  end
end
