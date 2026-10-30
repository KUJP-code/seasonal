# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Regular-day afternoon price settings' do
  before { sign_in create(:admin) }

  it 'saves the optional price from the admin form and allows clearing it' do
    prices = create(:member_prices)
    courses = prices.courses
    get edit_price_list_path(id: prices.id, locale: :ja)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('price_list[regular_day_afternoon_price]')

    patch price_list_path(id: prices.id),
          params: { price_list: { regular_day_afternoon_price: '2700' } }
    expect(response).to redirect_to(price_lists_path)
    expect(prices.reload.regular_day_afternoon_price).to eq(2700)
    expect(prices.courses).to eq(courses)

    patch price_list_path(id: prices.id),
          params: { price_list: { regular_day_afternoon_price: '' } }
    expect(prices.reload.regular_day_afternoon_price).to be_nil
  end

  it 'shows validation errors instead of saving a negative price' do
    prices = create(:member_prices)

    patch price_list_path(id: prices.id),
          params: { price_list: { regular_day_afternoon_price: '-1' } }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(prices.reload.regular_day_afternoon_price).to be_nil
  end
end
