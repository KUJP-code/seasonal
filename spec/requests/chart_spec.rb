# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'unrestricted viewer for Chart requests' do
  it 'allows access to index' do
    create(:event)
    get '/charts'
    expect(response).to have_http_status(:ok)
  end

  it 'allows access to show' do
    get "/charts/?category=activities&event=#{event.name.tr(' ', '+')}"
    expect(response).to have_http_status(:ok)
  end
end

RSpec.shared_examples 'manager of school for Chart requests' do
  it 'does not allow access to index' do
    get '/charts'
    expect(response).to have_http_status(:redirect)
  end

  it 'allows access to show' do
    get "/charts/#{user.managed_school.id}?category=activities&event=#{event.name.tr(' ', '+')}"
    expect(response).to have_http_status(:ok)
  end
end

RSpec.shared_examples 'unauthorized user for Chart requests' do
  let(:school) { create(:school) }

  it 'does not allow access to index' do
    get '/charts'
    expect(response).to have_http_status(:redirect)
  end

  it 'does not allow access to show' do
    get "/charts/#{school.id}?category=activities&event=#{event.name.tr(' ', '+')}"
    expect(response).to have_http_status(:redirect)
  end
end

RSpec.describe 'Chart Requests' do
  let(:event) { create(:event) }

  before do
    sign_in(user)
  end

  after do
    sign_out user
  end

  context 'when admin' do
    let(:user) { create(:admin) }

    it_behaves_like 'unrestricted viewer for Chart requests'
  end

  context 'when area manager' do
    let(:user) { create(:area_manager) }

    it_behaves_like 'unrestricted viewer for Chart requests'

    it 'cannot access stats for schools outside area' do
      school = create(:school)
      get "/charts/#{school.id}?category=activities&event=#{event.name.tr(' ', '+')}"
      expect(response).to have_http_status(:redirect)
    end
  end

  context 'when school manager' do
    let(:user) { create(:school_manager) }
    let(:school) { create(:school) }

    before do
      school.events << event
      user.managed_schools << school
    end

    it_behaves_like 'manager of school for Chart requests'

    it 'cannot access stats for other schools' do
      other_school = create(:school)
      get "/charts/#{other_school.id}?category=activities&event=#{event.name.tr(' ', '+')}"
      expect(response).to have_http_status(:redirect)
    end
  end

  context 'when statistician' do
    let(:user) { create(:statistician) }

    it_behaves_like 'unrestricted viewer for Chart requests'
  end

  context 'when customer' do
    let(:user) { create(:customer) }

    it_behaves_like 'unauthorized user for Chart requests'
  end
end
