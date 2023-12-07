# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'viewer for Area request' do
  it 'shows all areas' do
    get '/areas'
    expect(response).to have_http_status(:ok)
  end

  it 'shows single area' do
    get "/areas/#{area.id}"
    expect(response).to have_http_status(:ok)
  end
end

RSpec.shared_examples 'unauthorized user for Area request' do
  it 'is redirected from index because not authorized' do
    get '/areas'
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'is redirected from show because not authorized' do
    get "/areas/#{area.id}"
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'is redirected from new because not authorized' do
    get '/areas/new'
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'is redirected from create because not authorized' do
    post '/areas', params: { area: attributes_for(:area) }
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'is redirected from edit because not authorized' do
    get "/areas/#{area.id}/edit"
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'is redirected from update because not authorized' do
    patch "/areas/#{area.id}"
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'has no route for destroy' do
    delete "/areas/#{area.id}"
    expect(response).to have_http_status(:not_found)
  end
end

describe Area do
  let(:area) { create(:area) }

  before do
    sign_in(user)
  end

  after do
    sign_out(user)
  end

  context 'when admin' do
    let(:user) { create(:admin) }

    it_behaves_like 'viewer for Area request'

    it 'can access new area form' do
      get '/areas/new'
      expect(response).to have_http_status(:ok)
    end

    it 'can create new area' do
      expect { post '/areas', params: { area: attributes_for(:area) } }
        .to change(described_class, :count).by(1)
    end

    it 'can access edit area form' do
      get "/areas/#{area.id}/edit"
      expect(response).to have_http_status(:ok)
    end

    it 'can update area' do
      patch "/areas/#{area.id}", params: { area: attributes_for(:area, name: 'Updated Area') }
      expect(area.reload.name).to eq('Updated Area')
    end

    it 'has no route for destruction' do
      delete "/areas/#{area.id}"
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when manager of area' do
    let(:user) { create(:area_manager) }

    before do
      user.managed_areas << area
    end

    it_behaves_like 'viewer for Area request'

    it 'cannot access areas it does not manage' do
      user.managed_areas.clear
      get "/areas/#{area.id}"
      expect(flash[:alert]).to eq(I18n.t('not_authorized'))
    end

    it 'cannot access new area form' do
      get '/areas/new'
      expect(flash[:alert]).to eq(I18n.t('not_authorized'))
    end

    it 'cannot create new area' do
      expect { post '/areas', params: { area: attributes_for(:area) } }
        .not_to change(described_class, :count)
    end

    it 'cannot access edit area form' do
      get "/areas/#{area.id}/edit"
      expect(flash[:alert]).to eq(I18n.t('not_authorized'))
    end

    it 'cannot update area' do
      patch "/areas/#{area.id}", params: { area: attributes_for(:area, name: 'Updated Area') }
      expect(flash[:alert]).to eq(I18n.t('not_authorized'))
    end
  end

  context 'when school manager' do
    let(:user) { create(:school_manager) }

    it_behaves_like 'unauthorized user for Area request'
  end

  context 'when statistician' do
    let(:user) { create(:statistician) }

    it_behaves_like 'unauthorized user for Area request'
  end

  context 'when customer' do
    let(:user) { create(:customer) }

    it_behaves_like 'unauthorized user for Area request'
  end
end
