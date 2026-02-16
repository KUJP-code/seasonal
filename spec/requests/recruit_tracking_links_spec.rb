# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Recruit tracking links' do
  let(:index_path) { recruit_tracking_links_path(locale: :ja) }

  it 'allows admin to view tracking links' do
    sign_in create(:admin)
    create(:recruit_tracking_link, slug: 'admin-link')

    get index_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include('admin-link')
  end

  it 'blocks non-admin users' do
    sign_in create(:statistician)

    get index_path

    expect(response).to have_http_status(:found)
  end

  it 'allows admin to create a tracking link' do
    sign_in create(:admin)

    expect do
      post recruit_tracking_links_path(locale: :ja),
           params: {
             recruit_tracking_link: {
                name: 'Tokyo SM',
                slug: 'tokyo-sm'
              }
            }
    end.to change(RecruitTrackingLink, :count).by(1)

    expect(response).to redirect_to(recruit_tracking_links_path(locale: :en))
  end

  it 'removes a tracking link from the management list without deleting the record' do
    sign_in create(:admin)
    link = create(:recruit_tracking_link, active: true)

    patch remove_recruit_tracking_link_path(link, locale: :ja)
    expect(link.reload.active).to be(false)
    expect(RecruitTrackingLink.find(link.id)).to be_present
  end

  it 'reactivates an existing removed slug when creating again' do
    sign_in create(:admin)
    create(:recruit_tracking_link, slug: 'tokyo-sm', active: false, name: 'Old Name')

    expect do
      post recruit_tracking_links_path(locale: :ja),
           params: { recruit_tracking_link: { name: 'Tokyo SM', slug: 'tokyo-sm' } }
    end.not_to change(RecruitTrackingLink, :count)

    link = RecruitTrackingLink.find_by(slug: 'tokyo-sm')
    expect(link).to be_active
    expect(link.name).to eq('Tokyo SM')
  end
end
