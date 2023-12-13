# frozen_string_literal: true

require 'rails_helper'

def add_school_for_manager(school)
  if user.school_manager?
    user.managed_schools << school
  elsif user.area_manager?
    user.managed_areas << create(:area)
    user.managed_areas.first.schools << school
  end

  user.save
end

RSpec.shared_examples 'viewer for Survey request' do
  it 'allows access to index' do
    get '/surveys'
    expect(response).to have_http_status(:success)
  end

  it 'allows access to show' do
    school = create(:school)
    add_school_for_manager(school)
    get "/surveys/#{survey.id}"
    expect(response).to have_http_status(:success)
  end

  it 'does not allow access to new' do
    get '/surveys/new'
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'does not allow access to create' do
    survey_attributes = attributes_for(:survey)
    expect { post '/surveys', params: { survey: survey_attributes } }
      .not_to change(Survey, :count)
  end

  it 'does not allow access to edit' do
    get "/surveys/#{survey.id}/edit"
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'does not allow access to update' do
    survey_attributes = attributes_for(:survey, name: 'New Name')
    expect { patch "/surveys/#{survey.id}", params: { survey: survey_attributes } }
      .not_to change(survey, :name)
  end
end

RSpec.shared_examples 'unauthorized user for Survey request' do
  it 'does not allow access to index' do
    get '/surveys'
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'does not allow access to show' do
    get "/surveys/#{survey.id}"
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'does not allow access to new' do
    get '/surveys/new'
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'does not allow access to create' do
    survey_attributes = attributes_for(:survey)
    expect { post '/surveys', params: { survey: survey_attributes } }
      .not_to change(Survey, :count)
  end

  it 'does not allow access to edit' do
    get "/surveys/#{survey.id}/edit"
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'does not allow access to update' do
    survey_attributes = attributes_for(:survey, name: 'New Name')
    expect { patch "/surveys/#{survey.id}", params: { survey: survey_attributes } }
      .not_to change(survey, :name)
  end
end

RSpec.describe Survey do
  let(:survey) { create(:survey) }

  before do
    sign_in user
  end

  after do
    sign_out user
  end

  context 'when admin' do
    let(:user) { create(:admin) }
    let(:school) { create(:school) }

    it 'allows access to index' do
      get '/surveys'
      expect(response).to have_http_status(:success)
    end

    it 'allows access to show' do
      create(:school)
      get "/surveys/#{survey.id}"
      expect(response).to have_http_status(:success)
    end

    it 'allows access to new' do
      get '/surveys/new'
      expect(response).to have_http_status(:success)
    end

    it 'allows access to create' do
      survey_attributes = attributes_for(:survey)
      expect { post '/surveys', params: { survey: survey_attributes } }
        .to change(described_class, :count).by(1)
    end

    it 'allows access to edit' do
      get "/surveys/#{survey.id}/edit"
      expect(response).to have_http_status(:success)
    end

    it 'allows access to update' do
      survey_attributes = attributes_for(:survey, name: 'New Name')
      expect { patch "/surveys/#{survey.id}", params: { survey: survey_attributes } }
        .to change { survey.reload.name }.to('New Name')
    end
  end

  context 'when area_manager' do
    let(:user) { create(:area_manager) }

    it_behaves_like 'viewer for Survey request'
  end

  context 'when school_manager' do
    let(:user) { create(:school_manager) }

    it_behaves_like 'viewer for Survey request'
  end

  context 'when statistician' do
    let(:user) { create(:statistician) }

    it_behaves_like 'viewer for Survey request'
  end

  context 'when customer' do
    let(:user) { create(:customer) }

    it_behaves_like 'unauthorized user for Survey request'
  end
end
