# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Area do
  let(:valid_area) { build(:area) }
  let(:area) { create(:area) }

  context 'when valid' do
    it 'saves' do
      valid = valid_area.save
      expect(valid).to be true
    end
  end

  context 'when invalid' do
    it "doesn't save without a name" do
      valid_area.name = nil
      valid = valid_area.save
      expect(valid).to be false
    end

    it "doesn't save without a manager" do
      valid_area.manager = nil
      valid = valid_area.save
      expect(valid).to be false
    end
  end

  context 'with manager' do
    it 'knows its manager' do
      am = create(:am_user)
      managed_area = create(:area, manager: am)
      manager = managed_area.manager
      expect(manager).to be am
    end

    it "it's manager knows it" do
      am = create(:am_user)
      managed_area = create(:area, manager: am)
      manager_area = am.managed_area
      expect(manager_area).to eq managed_area
    end
  end

  context 'with schools' do
    let(:schools) { create_list(:school, 10) }

    it 'knows its schools' do
      schools.each do |school|
        area.schools << school
      end
      area_schools = area.schools
      expect(area_schools).to eq schools
    end

    it 'its schools know it' do
      area.schools = schools
      school_area = area.schools[rand(0..9)].area
      expect(school_area).to be area
    end

    context 'with users' do
      let(:school) { create(:school, area: area) }
      let(:users) { create_list(:customer_user, 3) }

      before do
        users.each do |user|
          school.users << user
        end
      end

      it 'knows its users through school' do
        area_users = area.users
        expect(area_users).to eq users
      end

      it 'users know their area through school' do
        user_area = users[rand(0..2)].area
        expect(user_area).to eq area
      end
    end

    context 'with children' do
      let(:school) { create(:school, area: area) }
      let(:children) { create_list(:child, 3) }

      before do
        children.each do |child|
          school.children << child
        end
      end

      it 'knows its children through school' do
        area_children = area.children
        expect(area_children).to eq children
      end

      it 'children know their area through school' do
        child_area = children[rand(0..2)].area
        expect(child_area).to eq area
      end
    end
  end
end
