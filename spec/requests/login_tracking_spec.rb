# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Login tracking' do
  %i[admin school_manager area_manager human_resources statistician].each do |role|
    it "records successful logins for #{role}, but not ordinary requests or failed logins" do
      user = create(role, password: 'ValidPassword123!',
                          confirmed_at: Time.current, allowed_ips: ['*'])
      path = user_session_path(locale: :ja)
      post path, params: { user: { email: user.email, password: 'wrong' } }
      expect(user.reload.sign_in_count).to eq(0)

      post path, params: { user: { email: user.email, password: 'ValidPassword123!' } },
                 headers: { 'REMOTE_ADDR' => '192.0.2.10' }
      expect(user.reload.sign_in_count).to eq(1)
      expect(user.current_sign_in_at).to be_present
      expect(user.current_sign_in_ip).to eq('192.0.2.10')
      first_login = user.current_sign_in_at
      get root_path(locale: :ja)
      expect(user.reload.sign_in_count).to eq(1)

      delete destroy_user_session_path(locale: :ja)
      post path, params: { user: { email: user.email, password: 'ValidPassword123!' } },
                 headers: { 'REMOTE_ADDR' => '192.0.2.11' }
      expect(user.reload.sign_in_count).to eq(2)
      expect(user.last_sign_in_at).to eq(first_login)
      expect(user.current_sign_in_ip).to eq('192.0.2.11')
      expect(user.last_sign_in_ip).to eq('192.0.2.10')
    end
  end

  it 'does not track customer logins' do
    user = create(:customer, password: 'ValidPassword123!', confirmed_at: Time.current)
    post user_session_path(locale: :ja),
         params: { user: { email: user.email, password: 'ValidPassword123!' } }
    expect(user.reload.sign_in_count).to eq(0)
    expect(user.current_sign_in_at).to be_nil
    expect(user.current_sign_in_ip).to be_nil
  end

  it 'links to separate staff stats from the staff list' do
    user = create(:human_resources, current_sign_in_at: Time.current,
                                    current_sign_in_ip: '192.0.2.42', sign_in_count: 12)
    sign_in create(:admin)
    get staff_users_path(locale: :ja)
    expect(response.body).to include('Staff Stats', stats_staff_users_path(locale: :en))
    expect(response.body).not_to include('192.0.2.42', 'Last login (JST)')
    get stats_staff_users_path(locale: :ja)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Last login (JST)', '192.0.2.42', user.email)
  end

  it 'does not expose staff login metadata to recruiters' do
    create(:admin, current_sign_in_ip: '192.0.2.42')
    sign_in create(:human_resources)
    get staff_users_path(locale: :ja)
    expect(response.body).not_to include('192.0.2.42', 'Staff Stats')
    get stats_staff_users_path(locale: :ja)
    expect(response).to redirect_to(root_path(locale: :ja))
    expect(response.body).not_to include('192.0.2.42')
  end
end
