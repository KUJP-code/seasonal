# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'viewer for Event request' do
  it 'allows viewing events' do
    get "/events/#{event.id}?child=#{child.id}"
    expect(response).to have_http_status(:ok)
  end

  it 'allows viewing event index' do
    get '/events'
    expect(response).to have_http_status(:ok)
  end
end

RSpec.shared_examples 'user unauthorized to request Event changes' do
  it 'is redirected from new because not authorized' do
    get '/events/new'
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'is redirected from create because not authorized' do
    post '/events', params: { event: attributes_for(:event) }
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'is redirected from edit because not authorized' do
    get "/events/#{event.id}/edit"
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'is redirected from update because not authorized' do
    patch "/events/#{event.id}", params: { event: attributes_for(:event) }
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end
end

RSpec.shared_examples 'user unauthorized to request Event attendance' do
  it 'is redirected from attendance because not authorized' do
    get "/children?id=#{event.id}&source=event"
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end
end

describe Event do
  let(:event) { create(:event) }
  let(:child) do
    parent = create(:customer)
    create(:child, parent: parent)
  end

  before do
    sign_in(user)
  end

  after do
    sign_out(user)
  end

  context 'when admin' do
    let(:user) { create(:admin) }

    it_behaves_like 'viewer for Event request'

    it 'allows access to new event form' do
      get '/events/new'
      expect(response).to have_http_status(:ok)
    end

    it 'allows access to create new event' do
      event # needs to be referenced here so lazy loaded & not counted as new one
      expect do
        post '/events',
             params: {
               event: attributes_for(
                 :event,
                 school_id: event.school_id
               )
             }
      end
        .to change(described_class, :count).by(1)
    end

    it 'allows access to edit event form' do
      get "/events/#{event.id}/edit"
      expect(response).to have_http_status(:ok)
    end

    it 'allows access to update event' do
      patch "/events/#{event.id}", params: {
        event: attributes_for(
          :event,
          name: 'Updated Name',
          school_id: event.school_id
        )
      }
      expect(event.reload.name).to eq('Updated Name')
    end

    it 'has no route for destroy event' do
      delete "/events/#{event.id}"
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when area manager' do
    let(:user) { create(:area_manager) }

    it_behaves_like 'viewer for Event request'
    it_behaves_like 'user unauthorized to request Event changes'
  end

  context 'when school manager' do
    let(:user) { create(:school_manager) }

    it_behaves_like 'viewer for Event request'
    it_behaves_like 'user unauthorized to request Event changes'
  end

  context 'when statistician' do
    let(:user) { create(:statistician) }

    it 'is redirected from index because not authorized' do
      get '/events'
      expect(flash[:alert]).to eq(I18n.t('not_authorized'))
    end

    it 'is redirected from show because not authorized' do
      get "/events/#{event.id}?child=#{child.id}"
      expect(flash[:alert]).to eq(I18n.t('not_authorized'))
    end

    it_behaves_like 'user unauthorized to request Event changes'
    it_behaves_like 'user unauthorized to request Event attendance'
  end

  context 'when customer' do
    let(:user) { create(:customer) }
    let(:child) do
      create(
        :child,
        invoices: [create(:invoice, event: event)]
      )
    end

    # FIXME: Occasionally fails to work for show
    before do
      user.children << child
      user.save
      user.children.reload
    end

    it 'cannot acess Event#show for other children' do
      child.update(parent_id: nil)
      user.save
      get "/events/#{event.id}?child=#{child.id}"
      expect(flash[:alert]).to eq(I18n.t('not_authorized'))
    end

    it_behaves_like 'viewer for Event request'
    it_behaves_like 'user unauthorized to request Event changes'
    it_behaves_like 'user unauthorized to request Event attendance'
  end
end
