# frozen_string_literal: true

require 'rails_helper'

def create_schools(user)
  school = create(:school)
  if user.school_manager?
    school.managers << user
  elsif user.area_manager?
    user.managed_areas << create(:area)
    user.managed_areas.first.schools << school
  end
end

RSpec.shared_examples 'staff for requests to ChildrenController' do
  it 'shows child index' do
    create_schools(user)
    get '/children'
    expect(response).to have_http_status(:ok)
  end

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

    it_behaves_like 'staff for requests to ChildrenController'
  end

  context 'when area manager' do
    let(:user) { create(:area_manager) }

    it_behaves_like 'staff for requests to ChildrenController'
  end

  context 'when school manager' do
    let(:user) { create(:school_manager) }

    it_behaves_like 'staff for requests to ChildrenController'
  end

  context 'when parent of child' do
    # FIXME: those requiring a parent occasionally fail with a 302
    let(:user) { create(:customer) }

    before do
      user.children << child
      user.save
      user.children.reload
    end

    it 'redirects home when child index requested' do
      get '/children'
      expect(response).to have_http_status(:redirect)
    end

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

    it 'redirects home when child deletion attempted' do
      delete "/children/#{child.id}"
      expect(flash[:alert]).to eq(I18n.t('not_authorized'))
    end
  end

  context 'when parent of different child' do
    let(:user) { create(:customer) }

    it 'redirects home when child index requested' do
      get '/children'
      expect(response).to have_http_status(:redirect)
    end

    it 'redirects home when child profile requested' do
      get "/children/#{child.id}"
      expect(flash[:alert]).to eq(I18n.t('not_authorized'))
    end

    it 'shows form for new child' do
      get '/children/new'
      expect(response).to have_http_status(:ok)
    end

    it 'redirects home when child creation attempted' do
      attributes = attributes_for(:form_child)
      post '/children', params: { child: attributes }
      expect(flash[:alert]).to eq(I18n.t('not_authorized'))
    end

    it 'redirects home when asked to edit child' do
      get "/children/#{child.id}/edit"
      expect(flash[:alert]).to eq(I18n.t('not_authorized'))
    end

    it 'redirects home when child update attempted' do
      attributes = attributes_for(:form_child, first_name: 'New', family_name: 'Name')
      patch "/children/#{child.id}", params: { child: attributes }
      expect(flash[:alert]).to eq(I18n.t('not_authorized'))
    end

    it 'redirects home when child deletion attempted' do
      delete "/children/#{child.id}"
      expect(flash[:alert]).to eq(I18n.t('not_authorized'))
    end
  end
end
