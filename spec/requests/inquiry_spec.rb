# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'staff for Inquiry request' do
  before do
    give_managers_access(user)
  end

  it 'allows viewing inquiry index' do
    get '/inquiries'
    expect(response).to have_http_status(:ok)
  end

  it 'allows access to new inquiry form' do
    get '/inquiries/new'
    expect(response).to have_http_status(:ok)
  end

  it 'allows access to create new inquiry' do
    school = create(:school)
    inquiry_attributes = attributes_for(:inquiry, school_id: school.id)
    expect { post '/inquiries', params: { inquiry: inquiry_attributes } }
      .to change(described_class, :count).by(1)
  end

  it 'allows access to edit inquiry form' do
    get "/inquiries/#{inquiry.id}/edit"
    expect(response).to have_http_status(:ok)
  end

  it 'allows access to update inquiry' do
    put "/inquiries/#{inquiry.id}",
        params: { inquiry: attributes_for(:inquiry, parent_name: 'updated') }
    expect(inquiry.reload.parent_name).to eq('updated')
  end

  it 'allows access to destroy inquiry' do
    inquiry
    expect { delete "/inquiries/#{inquiry.id}" }
      .to change(described_class, :count).by(-1)
  end
end

RSpec.shared_examples 'unauthorized user for Inquiry request' do
  it 'is redirected from index because not authorized' do
    get '/inquiries'
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'is redirected from new because not authorized' do
    get '/inquiries/new'
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'allows access to create new inquiry' do
    school = create(:school)
    inquiry_attributes = attributes_for(:inquiry, school_id: school.id)
    expect { post '/inquiries', params: { inquiry: inquiry_attributes } }
      .to change(described_class, :count).by(1)
  end

  it 'is redirected from edit because not authorized' do
    get "/inquiries/#{inquiry.id}/edit"
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'does not allow inquiry updates' do
    put "/inquiries/#{inquiry.id}", params: { inquiry: attributes_for(:inquiry, parent_name: 'updated') }
    expect(inquiry.reload.parent_name).not_to eq('updated')
  end

  it 'is redirected from destroy because not authorized' do
    inquiry
    expect { delete "/inquiries/#{inquiry.id}" }
      .not_to change(described_class, :count)
  end
end

def give_managers_access(user)
  if user.area_manager?
    user.managed_areas << inquiry.area
    user.save
  elsif user.school_manager?
    user.managed_schools << inquiry.school
    user.save
  end
end

describe Inquiry do
  let(:inquiry) { create(:inquiry) }

  before do
    sign_in(user) unless user.nil?
    create(:school)
    create(:setsumeikai)
  end

  after do
    sign_out(user) unless user.nil?
  end

  context 'when admin' do
    let(:user) { create(:admin) }

    it_behaves_like 'staff for Inquiry request'
  end

  context 'when area manager' do
    let(:user) { create(:area_manager) }

    it_behaves_like 'staff for Inquiry request'
  end

  context 'when school manager' do
    let(:user) { create(:school_manager) }

    it_behaves_like 'staff for Inquiry request'
  end

  context 'when statistician' do
    let(:user) { create(:statistician) }

    it_behaves_like 'unauthorized user for Inquiry request'
  end

  context 'when customer' do
    let(:user) { create(:customer) }

    it_behaves_like 'unauthorized user for Inquiry request'
  end

  context 'when not logged in/submitting from JP site form' do
    let(:user) { nil }

    it 'allows creation of inquiry through create_inquiry endpoint' do
      school = create(:school, managers: [create(:school_manager)])
      inquiry_attributes = attributes_for(:inquiry, school_id: school.id)
      expect { post '/create_inquiry.json', params: { inquiry: inquiry_attributes } }
        .to change(described_class, :count).by(1)
    end
  end
end
