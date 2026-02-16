# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Recruit applications' do
  describe 'POST /api/recruit_applications' do
    it 'creates a recruit application with required fields' do
      create(:recruit_tracking_link, slug: 'tokyo-sm-1')

      expect do
        post '/api/recruit_applications', params: {
          recruit_application: {
            role: 'sm',
            email: 'applicant@example.com',
            phone: '090-1234-5678',
            full_name: '採用 太郎',
            date_of_birth: '1998-05-12',
            full_address: '東京都港区1-2-3',
            privacy_policy_consent: true,
            utm_source: 'tiktok',
            utm_campaign: 'spring_hiring',
            tracking_link_slug: 'tokyo-sm-1'
          }
        }, as: :json
      end.to change(RecruitApplication, :count).by(1)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['status']).to eq(200)
      expect(json.dig('thank_you', 'ja')).to be_present
      expect(json.dig('thank_you', 'en')).to be_present

      record = RecruitApplication.last
      expect(record.role).to eq('sm')
      expect(record.utm_source).to eq('tiktok')
      expect(record.tracking_link_slug).to eq('tokyo-sm-1')
    end

    it 'returns validation errors for unknown tracking_link_slug' do
      post '/api/recruit_applications', params: {
        recruit_application: attributes_for(:recruit_application, tracking_link_slug: 'unknown-link')
      }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['errors'].join).to include('managed tracking link')
    end

    it 'returns validation errors when role is non-canonical' do
      post '/api/recruit_applications', params: {
        recruit_application: attributes_for(:recruit_application, role: 'SM')
      }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['errors'].join).to include('Role')
    end

    it 'returns validation errors when required fields are missing' do
      post '/api/recruit_applications', params: { recruit_application: { role: 'sm' } }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['errors']).to be_present
    end
  end

  describe 'GET /ja/recruit_applications' do
    let(:path) { recruit_applications_path(locale: :ja) }

    it 'redirects when not signed in' do
      get path
      expect(response).to have_http_status(:found)
    end

    it 'allows admin to view the list' do
      sign_in create(:admin)
      application = create(:recruit_application)

      get path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('Recruit Applications')
      expect(response.body).to include('View')
      expect(response.body).to include('Delete')
      expect(response.body).to include(recruit_application_path(application, locale: :en))
    end
  end

  describe 'GET /ja/recruit_applications/:id' do
    let(:application) { create(:recruit_application) }
    let(:path) { recruit_application_path(application, locale: :ja) }

    it 'redirects when not signed in' do
      get path
      expect(response).to have_http_status(:found)
    end

    it 'allows admin to view application details' do
      sign_in create(:admin)

      get path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('Recruit Application')
      expect(response.body).to include(application.full_name)
      expect(response.body).to include(application.email)
    end
  end

  describe 'DELETE /ja/recruit_applications/:id' do
    let!(:application) { create(:recruit_application) }
    let(:path) { recruit_application_path(application, locale: :ja) }

    it 'allows admin to delete application' do
      sign_in create(:admin)

      expect do
        delete path
      end.to change(RecruitApplication, :count).by(-1)

      expect(response).to redirect_to(recruit_applications_path(locale: :en))
    end

    it 'forbids statistician from deleting application' do
      sign_in create(:statistician)

      expect do
        delete path
      end.not_to change(RecruitApplication, :count)

      expect(response).to redirect_to(root_path(locale: :ja))
    end
  end
end
