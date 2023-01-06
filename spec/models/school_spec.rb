# frozen_string_literal: true

require 'rails_helper'

RSpec.describe School do
  let(:valid_school) { build(:school) }
  let(:school) { create(:school) }

  context 'when valid' do
    it 'saves' do
      valid = valid_school.save!
      expect(valid).to be true
    end

    it 'saves with a + in phone number' do
      valid_school.phone = '+815834653453'
      plus_valid = valid_school.save!
      expect(plus_valid).to be true
    end

    it 'saves with spaces in phone number' do
      valid_school.phone = '+8158 3465 3453'
      space_valid = valid_school.save!
      expect(space_valid).to be true
    end
  end

  context 'when invalid' do
    context 'when required values missing' do
      it "doesn't save without address" do
        valid_school.address = nil
        valid = valid_school.save
        expect(valid).to be false
      end

      it "doesn't save without name" do
        valid_school.name = nil
        valid = valid_school.save
        expect(valid).to be false
      end

      it "doesn't save without phone number" do
        valid_school.phone = nil
        valid = valid_school.save
        expect(valid).to be false
      end
    end

    context 'when required associations missing' do
      it "doesn't save without area" do
        valid_school.area = nil
        no_area_valid = valid_school.save
        expect(no_area_valid).to be false
      end
    end

    context 'when phone number invalid' do
      it "doesn't accept letters" do
        not_numbers = build(:school, phone: '79ug9723A')
        valid = not_numbers.save
        expect(valid).to be false
      end

      it "doesn't accept disallowed symbols" do
        illegal_symbols = build(:school, phone: '79%*9723#')
        valid = illegal_symbols.save
        expect(valid).to be false
      end
    end
  end

  context 'with area' do
    let(:schools) { create_list(:school, 10) }
    let(:area) { create(:area) }

    it 'knows its area' do
      new_school = create(:school, area: area)
      school_area = new_school.area
      expect(school_area).to be area
    end

    it 'can be added to a new area' do
      transfer_school = create(:school)
      area.schools << transfer_school
      area_schools = area.schools
      expect(area_schools).to include(transfer_school)
    end

    it "knows it's been added to a new area" do
      transfer_school = create(:school)
      area.schools << transfer_school
      t_school_area = transfer_school.area
      expect(t_school_area).to be area
    end

    it 'area knows its schools' do
      schools.each do |school|
        area.schools << school
      end
      area_schools = area.schools
      expect(area_schools).to eq schools
    end
  end

  context 'with manager' do
    subject(:managed_school) { create(:school, managers: [manager]) }

    let(:manager) { create(:sm_user) }
    let(:new_sm) { create(:sm_user) }

    it 'knows its manager' do
      managers = managed_school.managers
      expect(managers).to contain_exactly(manager)
    end

    it 'can remove a manager' do
      managed_school.managers.destroy(manager)
      managers = managed_school.managers
      expect(managers).to be_empty
    end

    it 'can add a manager' do
      managed_school.managers << new_sm
      managers = managed_school.managers
      expect(managers).to include(new_sm)
    end

    it 'can change managers' do
      managed_school.managers = [new_sm]
      new_managers = managed_school.managers
      expect(new_managers).to contain_exactly(new_sm)
    end

    it 'old manager knows its been removed as manager' do
      old_sm = managed_school.managers.first
      managed_school.managers = [new_sm]
      old_sm_areas = old_sm.managed_schools
      expect(old_sm_areas).not_to include(managed_school)
    end
  end

  context 'with customers' do
    let(:customer) { create(:customer_user) }

    it 'knows its customers' do
      school.users << customer
      school_customers = school.users.customers
      expect(school_customers).to contain_exactly(customer)
    end
  end

  context 'with children' do
    let(:child) { create(:child) }

    before do
      school.children << child
    end

    it 'knows its children' do
      school_children = school.children
      expect(school_children).to contain_exactly(child)
    end

    it 'can add new children' do
      school.children << child
      school_children = school.children
      expect(school_children).to include(child)
    end

    # necessary to call reload so the list of children is updated
    it 'knows children have moved to a different school' do
      new_school = create(:school)
      transfer_child = school.children.first
      new_school.children << transfer_child
      school_children = school.children.reload
      expect(school_children).not_to include(transfer_child)
    end

    it 'can unenroll children' do
      unenrolled_child = school.children.first
      expect { unenrolled_child.destroy }.to \
        change(Child.all, :count)
        .by(-1)
    end
  end

  context 'with events' do
    let(:events) { [create(:event, school: school), create(:event, school: school)] }

    it 'knows its events' do
      school_events = school.events
      expect(school_events).to match_array(events)
    end
  end

  context 'with time slots' do
    let(:event) { school.events.create(attributes_for(:event)) }
    let(:time_slot) { event.time_slots.create(attributes_for(:time_slot)) }

    it 'knows its time slots' do
      school_slots = school.time_slots
      expect(school_slots).to include(time_slot)
    end

    context 'with registrations' do
      it 'knows its registrations' do
        registration = time_slot.registrations.create(attributes_for(:registration))
        school_registrations = school.registrations
        expect(school_registrations).to contain_exactly(registration)
      end

      it 'knows its option registrations' do
        option = time_slot.options.create(attributes_for(:option))
        school_opt_reg = option.registrations.create(child: create(:child))
        school_opt_registrations = school.option_registrations
        expect(school_opt_registrations).to contain_exactly(school_opt_reg)
      end
    end

    context 'with options through time slots' do
      it 'knows its options' do
        option = time_slot.options.create(attributes_for(:option))
        school_options = school.options
        expect(school_options).to contain_exactly(option)
      end
    end
  end
end
