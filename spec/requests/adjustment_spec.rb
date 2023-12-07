# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'staff for Adjustment request' do
  it 'allows editing adjustments' do
    get "/adjustments/#{adjustment.invoice_id}/edit"
    expect(response).to have_http_status(:ok)
  end
end

RSpec.shared_examples 'customer for Adjustment request' do
  it 'is redirected because not authorized' do
    get "/adjustments/#{adjustment.invoice_id}/edit"
    expect(response).to have_http_status(:redirect)
  end
end

describe Adjustment do
  let(:adjustment) { create(:adjustment) }

  before do
    sign_in(user)
  end

  after do
    sign_out(user)
  end

  context 'when admin' do
    let(:user) { create(:admin) }

    it_behaves_like 'staff for Adjustment request'
  end

  context 'when area manager' do
    let(:user) { create(:area_manager) }

    it_behaves_like 'staff for Adjustment request'
  end

  context 'when school manager' do
    let(:user) { create(:school_manager) }

    it_behaves_like 'staff for Adjustment request'
  end

  context 'when statistician' do
    let(:user) { create(:statistician) }

    it_behaves_like 'customer for Adjustment request'
  end

  context 'when customer' do
    let(:user) { create(:customer) }

    it_behaves_like 'customer for Adjustment request'
  end
end
