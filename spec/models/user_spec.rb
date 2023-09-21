# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User' do
  let(:valid_user) { build(:user) }
  let(:user) { create(:user) }
  let(:school) { create(:school) }

  context 'when valid' do
    it 'saves the User' do
      saves = valid_user.save
      expect(saves).to be true
    end

    it 'role is customer by default' do
      role = user.role
      expect(role).to eq 'customer'
    end

    it 'saves with a + in phone number' do
      valid_user.phone = '+815834653453'
      plus_valid = valid_user.save!
      expect(plus_valid).to be true
    end

    it 'saves with spaces in phone number' do
      valid_user.phone = '+8158 3465 3453'
      space_valid = valid_user.save!
      expect(space_valid).to be true
    end

    it 'knows if it is staff member' do
      users = [create(:am_user), create(:sm_user), create(:admin_user)]
      staff = users.all?(&:staff?)
      expect(staff).to be true
    end

    with_versioning do
      it 'creates a paper trail on create' do
        valid_user.save
        expect(valid_user).to be_versioned
      end

      it 'creates a paper trail on update' do
        user.update(name: '吉田丸山')
        expect(user).to be_versioned
      end

      it 'creates a paper trail on destroy' do
        user.destroy
        expect(user).to be_versioned
      end

      it 'can be restored to previous version' do
        old_name = user.name
        user.update(name: '吉田丸山')
        user.paper_trail.previous_version.save
        reverted_name = user.reload.name
        expect(old_name).to eq reverted_name
      end
    end
  end

  context 'when invalid' do
    context 'when password is invalid' do
      it 'rejects passwords shorter than 10 characters' do
        short_pass = build(:user, password: 'short')
        valid = short_pass.save
        expect(valid).to be false
      end

      it 'rejects users with no password' do
        no_pass = build(:user, password: 'nil')
        valid = no_pass.save
        expect(valid).to be false
      end
    end

    context 'when email is invalid' do
      it 'rejects users with no email' do
        no_email = build(:user, email: 'nil')
        valid = no_email.save
        expect(valid).to be false
      end
    end

    context 'when phone number invalid' do
      it "doesn't accept letters" do
        not_numbers = build(:user, phone: '79ug9723A')
        valid = not_numbers.save
        expect(valid).to be false
      end

      it "doesn't accept disallowed symbols" do
        illegal_symbols = build(:user, phone: '79%*9723#')
        valid = illegal_symbols.save
        expect(valid).to be false
      end
    end
  end

  context 'when regular user' do
    it 'knows its school' do
      parent = create(:customer_user)
      parent.children << create(:child, school: school)
      parent_schools = parent.schools
      expect(parent_schools).to contain_exactly(school)
    end

    it "doesn't need a managed school" do
      no_managing = build(:user, managed_schools: [])
      no_managing_valid = no_managing.save
      expect(no_managing_valid).to be true
    end

    it "doesn't need a managed area" do
      no_managing = build(:user, managed_areas: [])
      no_managing_valid = no_managing.save
      expect(no_managing_valid).to be true
    end

    it 'knows its area through school' do
      parent = create(:customer_user)
      parent.children << create(:child, school: school)
      school_area = school.area
      parent_areas = parent.areas
      expect(parent_areas).to contain_exactly(school_area)
    end
  end

  context 'when area manager' do
    subject(:am) { create(:am_user) }

    let(:managed_area) { am.managed_areas.create(attributes_for(:area)) }
    let(:new_area) { create(:area) }

    it 'can create a managed area' do
      area_managers = managed_area.managers
      expect(area_managers).to contain_exactly(am)
    end

    it 'knows its managed area' do
      managed_areas = am.managed_areas
      expect(managed_areas).to contain_exactly(managed_area)
    end

    it "doesn't need a school" do
      no_school = build(:am_user)
      valid = no_school.save!
      expect(valid).to be true
    end

    it 'can change managed areas' do
      old_area = managed_area
      am.managed_areas = [new_area]
      new_areas = am.managed_areas
      expect(new_areas).not_to include(old_area)
    end

    it 'area knows its manager changed' do
      old_area = managed_area
      am.managed_areas = [new_area]
      current_managers = old_area.managers
      expect(current_managers).to be_empty
    end

    it 'can add new managed areas' do
      am.managed_areas << new_area
      managed_areas = am.managed_areas
      expect(managed_areas).to contain_exactly(managed_area, new_area)
    end
  end

  context 'when school manager' do
    subject(:sm) { create(:sm_user) }

    let(:managed_school) { sm.managed_schools.create(attributes_for(:school)) }
    let(:new_school) { create(:school) }

    it 'can create a managed school' do
      managers = managed_school.managers
      expect(managers).to contain_exactly(sm)
    end

    it 'knows its managed school' do
      managed_schools = sm.managed_schools
      expect(managed_schools).to contain_exactly(managed_school)
    end

    it "doesn't need a school" do
      no_school = build(:sm_user)
      valid = no_school.save!
      expect(valid).to be true
    end

    it 'can change managed schools' do
      old_school = managed_school
      sm.managed_schools = [new_school]
      new_schools = sm.managed_schools
      expect(new_schools).not_to include(old_school)
    end

    it 'school knows its manager changed' do
      old_school = managed_school
      sm.managed_schools = [new_school]
      current_managers = old_school.managers
      expect(current_managers).to be_empty
    end

    it 'can add new managed schools' do
      sm.managed_schools << new_school
      managed_schools = sm.managed_schools
      expect(managed_schools).to contain_exactly(managed_school, new_school)
    end
  end

  context 'with children' do
    let(:child) { create(:child, parent: user) }
    let(:time_slot) { create(:time_slot) }

    it 'knows its children' do
      user.children << child
      parent_children = user.children
      expect(parent_children).to contain_exactly(child)
    end

    it 'children know their parent' do
      child_parent = child.parent
      expect(child_parent).to eq user
    end

    it 'destroys all children when destroyed' do
      user.children << child
      expect { user.destroy }.to \
        change(Child, :count)
        .by(-1)
    end

    context 'with registrations through children' do
      it "knows its children's registrations" do
        child_registration = child.registrations.create(registerable: time_slot, invoice: create(:invoice))
        user_registrations = user.registrations
        expect(user_registrations).to contain_exactly(child_registration)
      end
    end

    context 'with events through children' do
      it "knows its children's registered events" do
        child_registration = child.registrations.create(registerable: time_slot, invoice: create(:invoice))
        registration_event = child_registration.event
        user_events = user.events
        expect(user_events).to contain_exactly(registration_event)
      end
    end

    context 'with time slots through children' do
      it "knows its children's time slots" do
        child.registrations.create(registerable: time_slot, invoice: create(:invoice))
        user_slots = user.time_slots
        expect(user_slots).to contain_exactly(time_slot)
      end
    end

    context 'with invoices through children' do
      it "knows its children's invoices" do
        invoice = child.invoices.create(total_cost: 0)
        child_invoices = child.invoices
        expect(child_invoices).to contain_exactly(invoice)
      end
    end
  end
end
