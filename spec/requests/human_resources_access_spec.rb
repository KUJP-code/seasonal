# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Human resources access' do
  let(:user) { create(:human_resources) }

  before do
    sign_in user
  end

  after do
    sign_out user
  end

  it 'redirects the authenticated root to recruit applications' do
    get root_path

    expect(response).to redirect_to(recruit_applications_path(locale: I18n.locale))
  end

  it 'redirects the user profile page to recruit applications' do
    get user_path(id: user.id)

    expect(response).to redirect_to(recruit_applications_path(locale: I18n.locale))
  end

  it 'allows access to recruit applications' do
    get recruit_applications_path

    expect(response).to have_http_status(:success)
  end
end
