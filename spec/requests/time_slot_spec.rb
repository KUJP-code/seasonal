# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'manager for TimeSlot requests' do
  it 'allows access to index' do
    get time_slots_path
    expect(response).to have_http_status(:success)
  end

  it 'does not allow access to new' do
    get new_time_slot_path(event: time_slot.event_id)
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'does not allow access to edit' do
    get edit_time_slot_path(id: time_slot.id)
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end
end

RSpec.shared_examples 'school manager for TimeSlot requests' do
  it 'does not allow updating time slots' do
    slot_attributes = attributes_for(:time_slot, name: 'new name')
    patch time_slot_path(id: time_slot.id, time_slot: slot_attributes)
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end
end

RSpec.shared_examples 'area manager for TimeSlot requests' do
  it 'allows updating time slots' do
    slot_attributes = attributes_for(:time_slot, name: 'new name')
    expect { patch time_slot_path(id: time_slot.id, time_slot: slot_attributes) }
      .to change { time_slot.reload.name }.to('new name')
  end
end

RSpec.shared_examples 'unauthorized user for TimeSlot requests' do
  it 'does not allow access to index' do
    get time_slots_path
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'does not allow access to new' do
    get new_time_slot_path(event: time_slot.event_id)
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'does not allow access to edit' do
    get edit_time_slot_path(id: time_slot.id)
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'does not allow updating time slots' do
    slot_attributes = attributes_for(:time_slot, name: 'new name')
    expect { patch time_slot_path(id: time_slot.id, time_slot: slot_attributes) }
      .not_to change(time_slot, :name)
  end

  it 'does not allow access to attendance' do
    get children_path(id: time_slot.id, source: 'time_slot')
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end
end

RSpec.describe TimeSlot do
  let(:time_slot) { create(:time_slot) }

  before do
    sign_in user
  end

  after do
    sign_out user
  end

  context 'when admin' do
    let(:user) { create(:admin) }

    it 'allows access to index' do
      create(:school)
      get time_slots_path
      expect(response).to have_http_status(:success)
    end

    it 'allows access to new' do
      get new_time_slot_path(event: time_slot.event_id)
      expect(response).to have_http_status(:success)
    end

    it 'allows access to edit' do
      get edit_time_slot_path(id: time_slot.id)
      expect(response).to have_http_status(:success)
    end

    it 'allows updating time slots' do
      slot_attributes = attributes_for(:time_slot, name: 'new name')
      expect { patch time_slot_path(id: time_slot.id, time_slot: slot_attributes) }
        .to change { time_slot.reload.name }.to('new name')
    end

    it 'allows access to attendance' do
      get children_path(id: time_slot.id, source: 'time_slot')
      expect(response).to have_http_status(:success)
    end
  end

  context 'when manager of TimeSlot school area' do
    let(:user) { create(:area_manager) }

    before do
      user.managed_areas << time_slot.school.area
      user.save
    end

    it 'allows access to attendance' do
      get children_path(id: time_slot.id, source: 'time_slot')
      expect(response).to have_http_status(:success)
    end

    it_behaves_like 'manager for TimeSlot requests'
    it_behaves_like 'area manager for TimeSlot requests'
  end

  context 'when manager of different area' do
    let(:user) { create(:area_manager) }

    before do
      user.managed_areas << create(:area)
      create(:school, area: user.managed_areas.first)
      user.save
    end

    it 'does not allow access to attendance' do
      get children_path(id: time_slot.id, source: 'time_slot')
      expect(flash[:alert]).to eq(I18n.t('not_authorized'))
    end

    it_behaves_like 'manager for TimeSlot requests'
    it_behaves_like 'school manager for TimeSlot requests'
  end

  context 'when manager of time slot school' do
    let(:user) { create(:school_manager) }

    before do
      user.managed_schools << time_slot.school
      user.save
    end

    it 'allows access to attendance' do
      get children_path(id: time_slot.id, source: 'time_slot')
      expect(response).to have_http_status(:success)
    end

    it_behaves_like 'manager for TimeSlot requests'
    it_behaves_like 'school manager for TimeSlot requests'
  end

  context 'when manager of different school' do
    let(:user) { create(:school_manager) }

    before do
      user.managed_schools << create(:school)
      user.save
    end

    it 'does not allow access to attendance' do
      get children_path(id: time_slot.id, source: 'time_slot')
      expect(flash[:alert]).to eq(I18n.t('not_authorized'))
    end

    it_behaves_like 'manager for TimeSlot requests'
    it_behaves_like 'school manager for TimeSlot requests'
  end

  context 'when statistician' do
    let(:user) { create(:statistician) }

    it_behaves_like 'unauthorized user for TimeSlot requests'
  end

  context 'when customer' do
    let(:user) { create(:customer) }

    it_behaves_like 'unauthorized user for TimeSlot requests'
  end
end
