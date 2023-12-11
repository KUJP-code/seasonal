# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'manager of setsumeikai school for Setsumeikai request' do
  it 'allows access to the show view' do
    get "/setsumeikais/#{setsumeikai.id}"
    expect(response).to have_http_status(:ok)
  end

  it 'allows access to create setsumeikais' do
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
    tomorrow = Time.zone.tomorrow
    setsumeikai_params = attributes_for(:setsumeikai, release_date: tomorrow)
    expect { patch "/setsumeikais/#{setsumeikai.id}", params: { setsumeikai: setsumeikai_params } }
      .not_to change(setsumeikai, :release_date)
  end

  it 'does not allow access to destroy the setsumeikai' do
    setsumeikai
    expect { delete "/setsumeikais/#{setsumeikai.id}" }
      .not_to change(Setsumeikai, :count)
  end
end

RSpec.shared_examples 'manager of involved school for Setsumeikai request' do
  it 'allows access to the show view' do
    create(:setsumeikai_involvement, setsumeikai: setsumeikai, school: school)
    get "/setsumeikais/#{setsumeikai.id}"
    expect(response).to have_http_status(:ok)
  end

  it 'does not allow access to create setsumeikais' do
    setsumeikai_attributes = attributes_for(
      :setsumeikai,
      setsumeikai_involvements: attributes_for(
        :setsumeikai_involvement,
        school_id: create(:school).id
      )
    )
    expect { post '/setsumeikais', params: { setsumeikai: setsumeikai_attributes } }
      .not_to change(Setsumeikai, :count)
  end

  it 'does not allow access to the edit view' do
    get "/setsumeikais/#{setsumeikai.id}/edit"
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'does not allow access to update the setsumeikai' do
    yesterday = Time.zone.yesterday
    setsumeikai_params = attributes_for(:setsumeikai, release_date: yesterday)
    expect { patch "/setsumeikais/#{setsumeikai.id}", params: { setsumeikai: setsumeikai_params } }
      .not_to change(setsumeikai, :release_date)
  end

  it 'does not allow access to destroy the setsumeikai' do
    setsumeikai
    expect { delete "/setsumeikais/#{setsumeikai.id}" }
      .not_to change(Setsumeikai, :count)
  end
end

RSpec.shared_examples 'staff for index request' do
  it 'allows access to the index view' do
    create_managed_school(user)
    get '/setsumeikais'
    expect(response).to have_http_status(:ok)
  end
end

def create_managed_school(user)
  if user.school_manager?
    user.managed_schools << create(:school)
  elsif user.area_manager?
    user.managed_areas << create(:area)
    user.managed_areas.first.schools << create(:school)
  else
    create(:school)
  end
  user.save
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
    let(:school) { create(:school) }

    it_behaves_like 'manager of setsumeikai school for Setsumeikai request'
    it_behaves_like 'staff for index request'
  end

  context 'when manager of setsumeikai area' do
    let(:user) { create(:area_manager) }
    let(:school) { create(:school, area: user.managed_areas.first) }

    before do
      user.managed_areas << setsumeikai.area
      user.save
    end

    it_behaves_like 'manager of setsumeikai school for Setsumeikai request'
    it_behaves_like 'staff for index request'
  end

  context 'when area manager of school involved in setsumeikai' do
    let(:user) { create(:area_manager) }
    let(:school) { create(:school) }

    before do
      user.managed_areas << create(:area)
      user.managed_areas.first.schools << school
      setsumeikai.involved_schools << school
      user.save
    end

    it_behaves_like 'manager of involved school for Setsumeikai request'
    it_behaves_like 'staff for index request'
  end

  context 'when manager of different area' do
    let(:user) { create(:area_manager) }

    it_behaves_like 'unauthorized user for Setsumeikai request'
    it_behaves_like 'staff for index request'
  end

  context 'when manager of setsumeikai school' do
    let(:user) { create(:school_manager) }
    let(:school) { setsumeikai.school }

    before do
      user.managed_schools << setsumeikai.school
      user.save
    end

    it_behaves_like 'manager of setsumeikai school for Setsumeikai request'
    it_behaves_like 'staff for index request'
  end

  context 'when manager of involved school' do
    let(:user) { create(:school_manager) }
    let(:school) { create(:school) }

    before do
      user.managed_schools << school
      user.save
    end

    it_behaves_like 'manager of involved school for Setsumeikai request'
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
