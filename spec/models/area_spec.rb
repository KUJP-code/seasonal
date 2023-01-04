# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Area do
  let(:area) { create(:managed_area) }

  context 'when valid' do
    subject(:valid_area) { build(:area) }

    it 'saves' do
      valid = valid_area.save!
      expect(valid).to be true
    end

    it 'saves without a manager' do
      valid_area.managers = []
      valid = valid_area.save!
      expect(valid).to be true
    end
  end

  context 'when invalid' do
    it "doesn't save without a name" do
      no_name = build(:area, name: nil)
      valid = no_name.save
      expect(valid).to be false
    end
  end

  context 'with manager' do
    subject(:managed_area) { create(:area, managers: [manager]) }

    let(:manager) { create(:am_user) }
    let(:new_am) { create(:am_user) }

    it 'knows its managers' do
      managers = managed_area.managers
      expect(managers).to contain_exactly(manager)
    end

    it 'can remove a manager' do
      managed_area.managers.destroy(manager)
      managers = managed_area.managers
      expect(managers).to be_empty
    end

    it 'can add a manager' do
      managed_area.managers << new_am
      managers = managed_area.managers
      expect(managers).to include(new_am)
    end

    it 'can change managers' do
      managed_area.managers = [new_am]
      new_managers = managed_area.managers
      expect(new_managers).to contain_exactly(new_am)
    end

    it 'old manager knows its been removed as manager' do
      old_am = managed_area.managers.first
      managed_area.managers = [new_am]
      old_am_areas = old_am.managed_areas
      expect(old_am_areas).not_to include(managed_area)
    end
  end

  context 'with schools' do
    let(:school) { create(:school, area: area) }

    it 'knows its schools' do
      area_schools = area.schools
      expect(area_schools).to contain_exactly(school)
    end

    context 'with users' do
      let(:user) { create(:customer_user, school: school) }

      it 'knows its users through school' do
        area_users = area.users
        expect(area_users).to contain_exactly(user)
      end
    end

    context 'with children' do
      let(:child) { create(:child, school: school) }

      it 'knows its children through school' do
        area_children = area.children
        expect(area_children).to contain_exactly(child)
      end
    end

    context 'with events' do
      let(:event) { create(:event, school: school) }

      it 'knows its events' do
        area_events = area.events
        expect(area_events).to contain_exactly(event)
      end
    end

    context 'with registrations' do
      let(:event) { create(:event, school: school) }
      let(:time_slot) { event.time_slots.create(attributes_for(:time_slot)) }

      it 'knows its registrations' do
        registration = time_slot.registrations.create(attributes_for(:registration))
        area_registrations = area.registrations
        expect(area_registrations).to contain_exactly(registration)
      end
    end
  end
end
