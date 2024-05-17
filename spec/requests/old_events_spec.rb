# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Old event requests' do
  let(:user) { create(:customer) }
  let(:child) { create(:child, parent: user) }
  let(:old_event) { create(:event, start_date: 2.days.ago, end_date: 1.day.ago) }

  before do
    sign_in user
  end

  it 'redirects home if visiting event that finished' do
    get event_path(id: old_event.id, child: child.id)
    expect(flash.alert).to eq("下記カレンダーよりご希望のアクティビティをクリックし、選択してください。\n<注意>すでに終了しているアクティビティは選択をしないようご注意ください。")
    expect(response).to redirect_to(root_path(locale: I18n.locale))
  end

  it 'loads event page if ongoing event' do
    event = create(:event, start_date: 1.day.ago, end_date: 1.day.from_now)
    get event_path(id: event.id, child: child.id)
    expect(response).to have_http_status(:success)
  end

  context 'when SM' do
    let(:user) { create(:school_manager, allowed_ips: ['127.0.0.1']) }

    it 'does not prevent SMs from visiting event that finished' do
      get event_path(id: old_event.id, child: child.id), env: { 'REMOTE_ADDR' => '127.0.0.1' }
      expect(response).to have_http_status(:success)
    end
  end
end
