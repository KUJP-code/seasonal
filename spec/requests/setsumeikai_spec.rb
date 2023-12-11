# frozen_string_literal: true

require 'rails_helper'

def create_school_for_user(user)
  school = create(:school)
  if user.school_manager?
    user.managed_schools << school
  elsif user.area_manager?
    user.managed_areas << create(:area)
    user.managed_areas.first.schools << school
  end
  user.save
  school
end

RSpec.shared_examples 'manager of setsumeikai for Setsumeikai request' do
  it 'allows access to the show view' do
    get "/setsumeikais/#{setsumeikai.id}"
    expect(response).to have_http_status(:ok)
  end

  it 'allows access to create setsumeikais' do
    school = create_school_for_user(user)
    setsu_attributes = attributes_for(
      :setsumeikai,
      school_id: school.id,
      setsumeikai_involvements_attributes: [
        { school_id: school.id }
      ]
    )
    expect { post '/setsumeikais', params: { setsumeikai: setsu_attributes } }
      .to change(Setsumeikai, :count)
  end

  it 'allows access to the edit view' do
    get "/setsumeikais/#{setsumeikai.id}/edit"
    expect(response).to have_http_status(:ok)
  end

  it 'allows access to update the setsumeikai' do
    today = Time.zone.today
    setsumeikai_params = attributes_for(:setsumeikai, release_date: today)
    expect { patch "/setsumeikais/#{setsumeikai.id}", params: { setsumeikai: setsumeikai_params } }
      .to change { setsumeikai.reload.release_date }.to(today)
  end

  it 'allows access to destroy the setsumeikai' do
    setsumeikai
    expect { delete "/setsumeikais/#{setsumeikai.id}" }
      .to change(Setsumeikai, :count)
  end
end

RSpec.shared_examples 'unauthorized user for Setsumeikai request' do
  it 'does not allow access to the show view' do
    get "/setsumeikais/#{setsumeikai.id}"
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'does not allow access to create setsumeikais' do
    expect { post '/setsumeikais', params: { setsumeikai: attributes_for(:setsumeikai) } }
      .not_to change(Setsumeikai, :count)
  end

  it 'does not allow access to the edit view' do
    get "/setsumeikais/#{setsumeikai.id}/edit"
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'does not allow access to update the setsumeikai' do
    setsumeikai_params = attributes_for(:setsumeikai, name: 'New Name')
    expect { patch "/setsumeikais/#{setsumeikai.id}", params: { setsumeikai: setsumeikai_params } }
      .not_to change(setsumeikai, :name)
  end

  it 'does not allow access to destroy the setsumeikai' do
    expect { delete "/setsumeikais/#{setsumeikai.id}" }
      .not_to change(Setsumeikai, :count)
  end
end

RSpec.shared_examples 'staff for index request' do
  it 'allows access to the index view' do
    get '/setsumeikais'
    expect(response).to have_http_status(:ok)
  end
end

RSpec.shared_examples 'unauthorized user for index request' do
  it 'does not allow access to the index view' do
    get '/setsumeikais'
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end
end

RSpec.describe SetsumeikaisController do
  let(:setsumeikai) { create(:setsumeikai) }

  before do
    sign_in user
  end

  after do
    sign_out user
  end

  context 'when admin' do
    let(:user) { create(:admin) }

    it_behaves_like 'manager of setsumeikai for Setsumeikai request'
  end

  context 'when manager of setsumeikai area' do
    let(:user) { create(:area_manager) }

    before do
      user.managed_areas << setsumeikai.area
      user.save
    end

    it_behaves_like 'manager of setsumeikai for Setsumeikai request'
    it_behaves_like 'staff for index request'
  end

  context 'when manager of different area' do
    let(:user) { create(:area_manager) }

    it_behaves_like 'unauthorized user for Setsumeikai request'
    it_behaves_like 'staff for index request'
  end

  context 'when manager of setsumeikai school' do
    let(:user) { create(:school_manager) }

    before do
      user.managed_schools << setsumeikai.school
      user.save
    end

    it_behaves_like 'manager of setsumeikai for Setsumeikai request'
    it_behaves_like 'staff for index request'
  end

  context 'when manager of different school' do
    let(:user) { create(:school_manager) }

    it_behaves_like 'unauthorized user for Setsumeikai request'
    it_behaves_like 'staff for index request'
  end

  context 'when statistician' do
    let(:user) { create(:statistician) }

    it_behaves_like 'unauthorized user for Setsumeikai request'
    it_behaves_like 'unauthorized user for index request'
  end

  context 'when customer' do
    let(:user) { create(:customer) }

    it_behaves_like 'unauthorized user for Setsumeikai request'
    it_behaves_like 'unauthorized user for index request'
  end
end
