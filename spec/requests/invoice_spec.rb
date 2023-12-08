# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'staff for Invoice requests' do
  it 'allows Invoice destruction' do
    invoice # needs to be referred to to be counted
    expect { delete "/invoices/#{invoice.id}" }
      .to change(described_class, :count).by(-1)
  end

  it 'allows copying invoices' do
    target = create(:child)
    put "/copy_invoice?event=#{invoice.event_id}&origin=#{invoice.child_id}&target=#{target.id}"
    expect(flash[:notice]).to eq(I18n.t('success', model: 'お申込', action: '更新'))
  end

  it 'allows merging invoices' do
    post '/merge_invoices', params: { merge_from: invoice.id, merge_to: create(:invoice).id }
    expect(flash[:notice]).to eq(I18n.t('success', model: 'お申込', action: '更新'))
  end

  it 'allows marking invoices seen' do
    post "/seen_invoice?id=#{invoice.id}", as: :turbo_stream
    expect(response.media_type).to eq Mime[:turbo_stream]
  end
end

RSpec.shared_examples 'authorized user for Invoice requests' do
  it 'allows access to child invoice index' do
    get "/invoices?child=#{invoice.child_id}"
    expect(response).to have_http_status(:ok)
  end

  it 'allows access to parent invoice index' do
    invoice.child.parent = create(:customer)
    get "/invoices?user=#{user.customer? ? user.id : invoice.child.parent_id}"
    expect(response).to have_http_status(:ok)
  end

  it 'allows access to show' do
    get "/invoices/#{invoice.id}"
    expect(response).to have_http_status(:ok)
  end

  it 'allows access to new' do
    get '/invoices/new'
    expect(response).to have_http_status(:ok)
  end

  it 'allows access to create' do
    parent = user.customer? ? user : create(:customer)
    child = user.customer? ? invoice.child : create(:child, parent: parent)
    invoice_attributes = attributes_for(
      :invoice,
      child_id: child.id,
      event_id: create(:event).id
    )
    expect { post '/invoices', params: { invoice: invoice_attributes } }
      .to change(described_class, :count).by(1)
  end

  it 'allows access to update' do
    event = create(:event)
    parent = create(:customer)
    invoice.child.parent = parent
    invoice.child.save
    invoice_attributes = attributes_for(:invoice, event_id: event.id)
    put "/invoices/#{invoice.id}", params: { invoice: invoice_attributes }
    expect(flash[:notice]).to eq(I18n.t('success', model: 'お申込', action: '更新'))
  end

  it 'allows access to confirmed placeholder' do
    get '/confirm_invoice'
    expect(response).to have_http_status(:ok)
  end
end

RSpec.shared_examples 'unauthorized user for Invoice requests' do
  it 'does not allow access to child invoice index' do
    get "/invoices?child=#{invoice.child_id}"
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'does not allow access to parent invoice index' do
    invoice.child.parent = create(:customer)
    get "/invoices?user=#{invoice.child.parent_id}"
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'does not allow access to show' do
    get "/invoices/#{invoice.id}"
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'allows access to new' do
    get '/invoices/new'
    expect(response).to have_http_status(:ok)
  end

  it 'does not allow access to create' do
    parent = create(:customer)
    child = create(:child, parent: parent)
    invoice_attributes = attributes_for(
      :invoice,
      child_id: child.id,
      event_id: create(:event).id
    )
    expect { post '/invoices', params: { invoice: invoice_attributes } }
      .not_to change(described_class, :count)
  end

  it 'does not allow access to update' do
    event = create(:event)
    parent = create(:customer)
    invoice.child.parent = parent
    invoice.child.save
    invoice_attributes = attributes_for(:invoice, event_id: event.id)
    put "/invoices/#{invoice.id}", params: { invoice: invoice_attributes }
    expect(invoice.reload.event_id).not_to eq(event.id)
  end

  it 'allows access to confirmed placeholder' do
    get '/confirm_invoice'
    expect(response).to have_http_status(:ok)
  end

  it 'does not allow access to destroy' do
    invoice # needs to be referred to to be counted
    expect { delete "/invoices/#{invoice.id}" }
      .not_to change(described_class, :count)
  end

  it 'does not allow access to merge' do
    post '/merge_invoices', params: { merge_from: invoice.id, merge_to: create(:invoice).id }
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'does not allow access to seen' do
    post "/seen_invoice?id=#{invoice.id}", as: :turbo_stream
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end
end

describe Invoice do
  let(:invoice) { create(:invoice) }

  before do
    sign_in(user)
  end

  after do
    sign_out(user)
  end

  context 'when admin' do
    let(:user) { create(:admin) }

    it_behaves_like 'staff for Invoice requests'
    it_behaves_like 'authorized user for Invoice requests'

    it 'has no route for edit' do
      get "/invoices/#{invoice.id}/edit"
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when area manager' do
    let(:user) { create(:area_manager) }

    it_behaves_like 'staff for Invoice requests'
    it_behaves_like 'authorized user for Invoice requests'
  end

  context 'when school manager' do
    let(:user) { create(:school_manager) }

    it_behaves_like 'staff for Invoice requests'
    it_behaves_like 'authorized user for Invoice requests'
  end

  context 'when statistician' do
    let(:user) { create(:statistician) }

    it_behaves_like 'unauthorized user for Invoice requests'
  end

  context 'when customer is parent of invoice child' do
    let(:user) { create(:customer) }

    before do
      user.children << invoice.child
      user.save
    end

    it_behaves_like 'authorized user for Invoice requests'
  end

  context 'when customer is not parent of invoice child' do
    let(:user) { create(:customer) }

    it_behaves_like 'unauthorized user for Invoice requests'
  end
end
