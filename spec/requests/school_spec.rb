# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'manager of school for School request' do
  it 'allows access to the show view' do
    get "/schools/#{school.id}"
    expect(response).to have_http_status(:ok)
  end

  it 'allows access to the edit view' do
    get "/schools/#{school.id}/edit"
    expect(response).to have_http_status(:ok)
  end

  it 'allows access to update the school' do
    school_params = attributes_for(:school, name: 'New Name')
    expect { patch "/schools/#{school.id}", params: { school: school_params } }
      .to change { school.reload.name }.from(school.name).to('New Name')
  end
end

RSpec.shared_examples 'unauthorized user for School request' do
  it 'does not allow access to the show view' do
    get "/schools/#{school.id}"
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'does not allow access to the edit view' do
    get "/schools/#{school.id}/edit"
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'does not allow access to update the school' do
    school_params = attributes_for(:school, name: 'New Name')
    expect { patch "/schools/#{school.id}", params: { school: school_params } }
      .not_to change(school, :name)
  end

  it 'does not allow access to create a school' do
    school_params = attributes_for(:school)
    expect { post '/schools', params: { school: school_params } }
      .not_to change(described_class, :count)
  end
end

RSpec.describe School do
  let(:school) { create(:school) }

  before do
    sign_in user
  end

  after do
    sign_out user
  end

  context 'when admin' do
    let(:user) { create(:admin) }

    it 'allows access to new school form' do
      get '/schools/new'
      expect(response).to have_http_status(:ok)
    end

    it 'allows access to create new school' do
      area = create(:area)
      expect { post '/schools', params: { school: attributes_for(:school, area_id: area.id) } }
        .to change(described_class, :count).by(1)
    end

    it_behaves_like 'manager of school for School request'
  end

  context "when manager of school's area" do
    let(:user) { create(:area_manager) }

    before do
      user.managed_areas << school.area
      user.save
    end

    it_behaves_like 'manager of school for School request'
  end

  context 'when manager of different area' do
    let(:user) { create(:area_manager) }

    it_behaves_like 'unauthorized user for School request'
  end

  context 'when manager of school' do
    let(:user) { create(:school_manager) }

    before do
      user.managed_schools << school
      user.save
    end

    it_behaves_like 'manager of school for School request'
  end

  context 'when manager of different school' do
    let(:user) { create(:school_manager) }

    it_behaves_like 'unauthorized user for School request'
  end

  context 'when statistician' do
    let(:user) { create(:statistician) }

    it 'allows access to the show view' do
      get "/schools/#{school.id}"
      expect(response).to have_http_status(:ok)
    end

    it 'does not allow access to the edit view' do
      get "/schools/#{school.id}/edit"
      expect(flash[:alert]).to eq(I18n.t('not_authorized'))
    end

    it 'does not allow access to update the school' do
      school_params = attributes_for(:school, name: 'New Name')
      expect { patch "/schools/#{school.id}", params: { school: school_params } }
        .not_to change(school, :name)
    end

    it 'does not allow access to create a school' do
      school_params = attributes_for(:school)
      expect { post '/schools', params: { school: school_params } }
        .not_to change(described_class, :count)
    end
  end

  context 'when customer' do
    let(:user) { create(:customer) }

    it_behaves_like 'unauthorized user for School request'
  end
end
