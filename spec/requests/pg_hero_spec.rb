# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PgHero' do
  before do
    sign_in user
  end

  after do
    sign_out user
  end

  context 'when admin who is not User 1' do
    let(:user) { create(:admin) }

    it 'cannot access the dashboard' do
      get pg_hero_path
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when area manager' do
    let(:user) { create(:area_manager) }

    it 'cannot access the dashboard' do
      get pg_hero_path
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when school manager' do
    let(:user) { create(:school_manager) }

    it 'cannot access the dashboard' do
      get pg_hero_path
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when statistician' do
    let(:user) { create(:statistician) }

    it 'cannot access the dashboard' do
      get pg_hero_path
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when customer' do
    let(:user) { create(:customer) }

    it 'cannot access the dashboard' do
      get pg_hero_path
      expect(response).to have_http_status(:not_found)
    end
  end
end
