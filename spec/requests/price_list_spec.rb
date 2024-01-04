# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'unauthorized user for PriceList request' do
  it 'is redirected from index because not authorized' do
    get '/price_lists'
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'is redirected from new because not authorized' do
    get '/price_lists/new'
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'is redirected from edit because not authorized' do
    get "/price_lists/#{price_list.id}/edit"
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'is redirected from create because not authorized' do
    post '/price_lists', params: { price_list: attributes_for(:member_prices) }
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'is redirected from update because not authorized' do
    patch "/price_lists/#{price_list.id}",
          params: { price_list: attributes_for(:member_prices) }
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end
end

RSpec.describe PriceList do
  let(:price_list) { create(:member_prices) }

  before do
    sign_in user
  end

  after do
    sign_out user
  end

  context 'when admin' do
    let(:user) { create(:admin) }

    it 'has no route for show' do
      get "/price_lists/#{price_list.id}"
      expect(response).to have_http_status(:not_found)
    end

    it 'has no route for destroy' do
      delete "/price_lists/#{price_list.id}"
      expect(response).to have_http_status(:not_found)
    end

    it 'allows access to index' do
      get '/price_lists'
      expect(response).to have_http_status(:ok)
    end

    it 'allows access to new' do
      get '/price_lists/new'
      expect(response).to have_http_status(:ok)
    end

    it 'allows access to create' do
      expect { post '/price_lists', params: { price_list: attributes_for(:member_prices) } }
        .to change(described_class, :count).by(1)
    end

    it 'allows access to edit' do
      get "/price_lists/#{price_list.id}/edit"
      expect(response).to have_http_status(:ok)
    end

    it 'allows access to update' do
      patch "/price_lists/#{price_list.id}",
            params: { price_list: attributes_for(:member_prices, course1: 96) }
      expect(price_list.reload['courses']['1']).to eq(96)
    end
  end

  context 'when area manager' do
    let(:user) { create(:area_manager) }

    it_behaves_like 'unauthorized user for PriceList request'
  end

  context 'when school manager' do
    let(:user) { create(:school_manager) }

    it_behaves_like 'unauthorized user for PriceList request'
  end

  context 'when statistician' do
    let(:user) { create(:statistician) }

    it_behaves_like 'unauthorized user for PriceList request'
  end

  context 'when customer' do
    let(:user) { create(:customer) }

    it_behaves_like 'unauthorized user for PriceList request'
  end
end
