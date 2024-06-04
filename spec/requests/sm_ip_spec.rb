# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SM redirect if not in school' do
  subject(:user) do
    create(:user, role: :school_manager, allowed_ips: ['127.0.0.1', '89.207.132.170'])
  end

  before do
    sign_in user
  end

  after do
    sign_out user
  end

  it 'allows regular access if in school' do
    get children_path, env: { 'REMOTE_ADDR' => '89.207.132.170' }
    expect(response).to have_http_status(:success)
  end

  context 'when not in school' do
    let(:non_school_ip) { '8.8.8.8' }

    it 'redirects to profile' do
      get children_path, env: { 'REMOTE_ADDR' => non_school_ip }
      expect(response).to redirect_to(user_path(user))
    end

    it 'tells the SM to contact Leroy if incorrectly redirected' do
      get children_path, env: { 'REMOTE_ADDR' => non_school_ip }
      expect(flash[:alert]).to eq(I18n.t('not_in_school'))
    end

    it 'allows access to own profile' do
      get user_path(locale: I18n.locale, id: user), env: { 'REMOTE_ADDR' => non_school_ip }
      expect(response).to have_http_status(:success)
    end

    it 'allows signing out' do
      delete destroy_user_session_url(locale: I18n.locale, _method: :delete),
             env: { 'REMOTE_ADDR' => non_school_ip }
      expect(response).to redirect_to(new_user_session_path(locale: I18n.locale))
    end

    it 'allows access if only allowed ip is wildcard (*)' do
      user.update(allowed_ips: ['*'])
      get children_path, env: { 'REMOTE_ADDR' => non_school_ip }
      expect(response).to have_http_status(:success)
    end

    it 'allows access if wildcard is part of allowed ips' do
      user.update(allowed_ips: ['127.0.0.1', '*'])
      get children_path, env: { 'REMOTE_ADDR' => non_school_ip }
      expect(response).to have_http_status(:success)
    end

    it 'denies access if allowed_ips empty' do
      user.update(allowed_ips: [])
      get children_path, env: { 'REMOTE_ADDR' => non_school_ip }
      expect(flash[:alert]).to eq(I18n.t('not_in_school'))
    end

    it 'denies access if allowed_ips nil' do
      user.update(allowed_ips: nil)
      get children_path, env: { 'REMOTE_ADDR' => non_school_ip }
      expect(flash[:alert]).to eq(I18n.t('not_in_school'))
    end
  end
end
