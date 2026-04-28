# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Staff users' do
  before do
    sign_in create(:admin)
  end

  describe 'GET /staff_users/:id/edit' do
    it 'shows recruiter privileges for area managers' do
      staff_user = create(:area_manager)

      get edit_staff_user_path(staff_user, locale: :ja)

      expect(response).to have_http_status(:success)
      expect(response.body).to include('Recruiter privileges')
    end

    it 'shows recruiter privileges for statisticians' do
      staff_user = create(:statistician)

      get edit_staff_user_path(staff_user, locale: :ja)

      expect(response).to have_http_status(:success)
      expect(response.body).to include('Recruiter privileges')
    end
  end

  describe 'PATCH /staff_users/:id' do
    it 'updates recruiter privileges' do
      staff_user = create(:area_manager)

      patch staff_user_path(staff_user, locale: :ja),
            params: { user: { recruiter_privileges: '1' } }

      expect(response).to redirect_to(user_path(staff_user))
      expect(staff_user.reload).to be_recruiter_privileges
    end
  end
end
