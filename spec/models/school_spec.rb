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

      it "doesn't save without manager" do
        valid_school.manager = nil
        no_manager_valid = valid_school.save
        expect(no_manager_valid).to be false
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
    it 'knows its manager' do
      manager = create(:sm_user)
      new_school = create(:school, manager: manager)
      school_manager = new_school.manager
      expect(school_manager).to be manager
    end

    it 'manager knows its school' do
      manager = create(:sm_user)
      new_school = create(:school, manager: manager)
      manager_school = manager.managed_school
      expect(manager_school).to eq new_school
    end
  end

  context 'with customers' do
    let(:customers) { create_list(:customer_user, 10) }

    it 'knows its customers' do
      customers.each do |customer|
        school.users << customer
      end
      school_customers = school.users.customers
      expect(school_customers).to eq customers
    end

    it 'customers know their school' do
      customer = customers.first
      school.users << customer
      customer_school = customer.school
      expect(customer_school).to be school
    end
  end
end
