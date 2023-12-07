# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'a staff member' do
  it 'shows child profile' do
    get "/children/#{child.id}"
    expect(response).to have_http_status(:ok)
  end

  it 'shows form for new child' do
    get '/children/new'
    expect(response).to have_http_status(:ok)
  end

  it 'allows new child to be created' do
    attributes = attributes_for(:form_child)
    expect { post '/children', params: { child: attributes } }.to change(described_class, :count).by(1)
  end

  it 'allows editing child' do
    get "/children/#{child.id}/edit"
    expect(response).to have_http_status(:ok)
  end

  it 'allows child to be updated' do
    attributes = attributes_for(:form_child, first_name: 'New', family_name: 'Name')
    expect { patch "/children/#{child.id}", params: { child: attributes } }
      .to change { child.reload.name }
      .to('Name New')
  end

  it 'allows deleting child' do
    delete "/children/#{child.id}"
    expect(flash[:notice]).to eq(I18n.t('success', action: '削除', model: '生徒'))
  end
end

describe Child do
  let(:child) { create(:child) }

  before do
    sign_in(user)
  end

  after do
    sign_out(user)
  end

  context 'when admin' do
    let(:user) { create(:admin) }

    it_behaves_like 'a staff member'
  end

  context 'when area manager' do
    let(:user) { create(:area_manager) }

    it_behaves_like 'a staff member'
  end

  context 'when school manager' do
    let(:user) { create(:school_manager) }

    it_behaves_like 'a staff member'
  end

  context 'when parent of child' do
    let(:user) { create(:customer) }

    before do
      user.children << child
    end

    # FIXME: this one fails maybe 10% of the time with a 302????
    it 'shows child profile' do
      get "/children/#{child.id}"
      expect(response).to have_http_status(:ok)
    end

    it 'shows form for new child' do
      get '/children/new'
      expect(response).to have_http_status(:ok)
    end

    it 'allows new child to be created' do
      attributes = attributes_for(:form_child, parent_id: user.id)
      expect { post '/children', params: { child: attributes } }.to change(described_class, :count).by(1)
    end

    # FIXME: this one fails maybe 10% of the time with a 302????
    it 'allows editing child' do
      get "/children/#{child.id}/edit"
      expect(response).to have_http_status(:ok)
    end

    it 'allows child to be updated' do
      attributes = attributes_for(:form_child, first_name: 'New', family_name: 'Name', parent_id: user.id)
      expect { patch "/children/#{child.id}", params: { child: attributes } }
        .to change { child.reload.name }
        .to('Name New')
    end

    it 'does not allow deleting child' do
      delete "/children/#{child.id}"
      expect(flash[:alert]).to eq(I18n.t('not_authorized'))
    end
  end

  context 'when parent of different child' do
    let(:user) { create(:customer) }

    it 'redirects home when asked for child profile' do
      get "/children/#{child.id}"
      expect(response).to have_http_status(:redirect)
    end

    it 'shows form for new child' do
      get '/children/new'
      expect(response).to have_http_status(:ok)
    end

    it 'does not allow new child to be created' do
      attributes = attributes_for(:form_child)
      post '/children', params: { child: attributes }
      expect(flash[:alert]).to eq(I18n.t('not_authorized'))
    end

    it 'redirects home when asked to edit child' do
      get "/children/#{child.id}/edit"
      expect(response).to have_http_status(:redirect)
    end

    it 'does not allow child to be updated' do
      attributes = attributes_for(:form_child, first_name: 'New', family_name: 'Name')
      patch "/children/#{child.id}", params: { child: attributes }
      expect(flash[:alert]).to eq(I18n.t('not_authorized'))
    end

    it 'does not allow deleting child' do
      delete "/children/#{child.id}"
      expect(flash[:alert]).to eq(I18n.t('not_authorized'))
    end
  end
end
