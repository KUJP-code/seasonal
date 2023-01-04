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
  end

  context 'when role is specified' do
    it 'sets role as customer' do
      role = create(:customer_user).role
      expect(role).to eq 'customer'
    end

    it 'sets role as school manager' do
      role = create(:sm_user).role
      expect(role).to eq 'school_manager'
    end

    it 'sets role as area manager' do
      role = create(:am_user).role
      expect(role).to eq 'area_manager'
    end

    it 'sets role as admin' do
      role = create(:admin_user).role
      expect(role).to eq 'admin'
    end

    it 'can be confirmed with #customer?' do
      confirmable = create(:customer_user).customer?
      expect(confirmable).to be true
    end

    it 'can be confirmed with #school_manager?' do
      confirmable = create(:sm_user).school_manager?
      expect(confirmable).to be true
    end

    it 'can be confirmed with #area_manager?' do
      confirmable = create(:am_user).area_manager?
      expect(confirmable).to be true
    end

    it 'can be confirmed with #admin?' do
      confirmable = create(:admin_user).admin?
      expect(confirmable).to be true
    end
  end

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

  context 'when regular user' do
    it 'knows its school' do
      user_attr = attributes_for(:customer_user)
      customer = school.users.create(user_attr)
      customer_school = customer.school
      expect(customer_school).to be school
    end

    it "doesn't need a managed school" do
      no_managing = build(:user, managed_school: nil)
      no_managing_valid = no_managing.save
      expect(no_managing_valid).to be true
    end

    it "doesn't need a managed area" do
      no_managing = build(:user, managed_area: nil)
      no_managing_valid = no_managing.save
      expect(no_managing_valid).to be true
    end

    # Uses eq not be because you're comparing hashes converted from AR objects
    it 'knows its area through school' do
      customer = school.users.create(attributes_for(:customer_user))
      school_area = school.area
      customer_area = customer.area
      expect(school_area).to eq(customer_area)
    end
  end

  # Looks like I'll need to create areas through area managers
  context 'when area manager' do
    subject(:area_manager) { create(:am_user) }

    let(:area_attr) { attributes_for(:area) }
    let(:new_am) { create(:am_user) }

    it 'knows its managed area' do
      created_area = area_manager.create_managed_area(area_attr)
      managed_area = area_manager.managed_area
      expect(managed_area).to be created_area
    end

    it 'managed area knows manager' do
      created_area = area_manager.create_managed_area(area_attr)
      manager = created_area.manager
      expect(manager).to be area_manager
    end

    it "doesn't need a school" do
      no_school = build(:am_user)
      valid = no_school.save!
      expect(valid).to be true
    end

    # Gonna need to handle this by updating the existing am account and
    # creating a new one for the moving am, due to this issue
    # (https://github.com/rails/rails/issues/43096)
    it 'can change areas' do
      created_area = area_manager.create_managed_area(area_attr)
      old_manager = created_area.manager.email
      created_area.manager.update(id: area_manager.id, email: 'new@gmail.com', password: 'newpasswordpassword')
      new_manager = created_area.manager.email
      expect(new_manager).not_to eq old_manager
    end

    it 'area knows its manager changed' do
      created_area = area_manager.create_managed_area(area_attr)
      created_area.manager = new_am
      current_manager = created_area.manager
      expect(current_manager).to be new_am
    end
  end

  context 'when school manager' do
    subject(:school_manager) { create(:sm_user) }

    let(:school_attr) { attributes_for(:school) }
    let(:new_sm) { create(:sm_user) }

    it 'knows its managed school' do
      managed_school = school_manager.create_managed_school(attributes_for(:school))
      user_school = school_manager.managed_school
      expect(user_school).to be managed_school
    end

    it 'managed school knows manager' do
      managed_school = school_manager.create_managed_school(attributes_for(:school))
      manager = managed_school.manager
      expect(manager).to be school_manager
    end

    it "doesn't need a school" do
      no_school = build(:sm_user)
      valid = no_school.save!
      expect(valid).to be true
    end

    # Gonna need to handle this by updating the existing sm account and
    # creating a new one for the moving sm, due to this issue
    # (https://github.com/rails/rails/issues/43096)
    it 'can change schools' do
      created_school = school_manager.create_managed_school(school_attr)
      old_manager = created_school.manager.email
      created_school.manager.update(id: school_manager.id, email: 'new@gmail.com', password: 'newpasswordpassword')
      new_manager = created_school.manager.email
      expect(new_manager).not_to eq old_manager
    end

    it 'area knows its manager changed' do
      created_school = school_manager.create_managed_school(school_attr)
      created_school.manager = new_sm
      current_manager = created_school.manager
      expect(current_manager).to be new_sm
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
      user.destroy
      expect(Child.all).to be_empty
    end

    context 'with registrations' do
      it 'knows its childrens registrations' do
        child_registration = child.registrations.create(registerable: time_slot)
        user_registrations = user.registrations
        expect(user_registrations).to contain_exactly(child_registration)
      end
    end

    context 'with events' do
      it 'knows its childrens registered events' do
        child_registration = child.registrations.create(registerable: time_slot)
        registration_event = child_registration.event
        user_events = user.events
        expect(user_events).to contain_exactly(registration_event)
      end
    end

    context 'with time slots' do
      it 'knows the time slots its children are attending' do
        child.registrations.create(registerable: time_slot)
        user_slots = user.time_slots
        expect(user_slots).to contain_exactly(time_slot)
      end
    end
  end
end
