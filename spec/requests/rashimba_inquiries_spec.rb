# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Rashimba inquiries' do
  let!(:inquiry) { create(:rashimba_inquiry, message: '<script>alert(1)</script>') }

  it 'requires authentication for every admin action' do
    get rashimba_inquiries_path
    expect(response).to have_http_status(:found)
    get rashimba_inquiry_path(id: inquiry.id)
    expect(response).to have_http_status(:found)
    patch rashimba_inquiry_path(id: inquiry.id),
          params: { rashimba_inquiry: { status: 'resolved' } }
    expect(response).to have_http_status(:found)
    delete rashimba_inquiry_path(id: inquiry.id)
    expect(response).to have_http_status(:found)
    expect(inquiry.reload.status).to eq('pending')
  end

  %i[customer school_manager area_manager statistician human_resources].each do |role|
    it "denies all read and write access to #{role}" do
      user = create(role, recruiter_privileges: true, allowed_ips: ['*'])
      sign_in user
      get rashimba_inquiries_path
      expect(response).to have_http_status(:found)
      expect(response.body).not_to include(inquiry.email)
      get rashimba_inquiry_path(id: inquiry.id)
      expect(response).to have_http_status(:found)
      patch rashimba_inquiry_path(id: inquiry.id),
            params: { rashimba_inquiry: { status: 'resolved' } }
      expect(response).to have_http_status(:found)
      delete rashimba_inquiry_path(id: inquiry.id)
      expect(response).to have_http_status(:found)
      expect(inquiry.reload.status).to eq('pending')
    end
  end

  it 'lets admins list, filter, and view escaped details' do
    sign_in create(:admin)
    parent = create(:rashimba_inquiry, :release_notification, email: 'parent@example.com')
    get rashimba_inquiries_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Rashimba Inquiries', 'View', 'Delete', inquiry.email,
                                     parent.email)
    expect(response.headers['Cache-Control']).to include('no-store')

    get rashimba_inquiries_path,
        params: { kind: 'release_notification', q: 'PARENT', status: 'pending' }
    expect(response.body).to include(parent.email)
    expect(response.body).not_to include(inquiry.email)

    get rashimba_inquiry_path(id: inquiry.id)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('&lt;script&gt;alert(1)&lt;/script&gt;')
    expect(response.body).not_to include('<script>alert(1)</script>')
  end

  it 'lets admins review but does not mass-assign submission fields' do
    sign_in create(:admin)
    patch rashimba_inquiry_path(id: inquiry.id), params: {
      rashimba_inquiry: { status: 'reviewed', admin_notes: 'Called back',
                          email: 'changed@example.com' }
    }
    expect(response).to have_http_status(:found)
    expect(inquiry.reload).to have_attributes(status: 'reviewed', admin_notes: 'Called back',
                                              email: 'inquirer@example.com')
  end

  it 'renders validation errors for an invalid review status' do
    sign_in create(:admin)
    patch rashimba_inquiry_path(id: inquiry.id), params: { rashimba_inquiry: { status: 'unknown' } }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(inquiry.reload.status).to eq('pending')
  end

  it 'lets admins permanently delete records' do
    sign_in create(:admin)
    expect do
      delete rashimba_inquiry_path(id: inquiry.id)
    end.to change(RashimbaInquiry, :count).by(-1)
    expect(response).to have_http_status(:see_other)
  end
end
