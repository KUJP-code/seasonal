# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SetsumeikaiPolicy do
  subject(:policy) { described_class.new(user, setsumeikai) }

  let(:setsumeikai) { create(:setsumeikai) }

  context 'when admin' do
    let(:user) { build(:admin) }

    it_behaves_like 'fully authorized user'
  end

  context 'when area manager' do
    let(:user) { build(:area_manager) }

    context 'when manager of setsumeikai area' do
      before do
        user.managed_areas << setsumeikai.area
        user.save
      end

      it_behaves_like 'fully authorized user'
    end

    context 'when manager of involved school area' do
      before do
        user.managed_areas << create(:area)
        school = create(:school, area: user.managed_areas.first)
        user.save
        create(:setsumeikai_involvement, school: school, setsumeikai: setsumeikai)
      end

      it_behaves_like 'viewer'
    end

    context 'when area manager of uninvolved area' do
      it_behaves_like 'unauthorized user'
    end
  end

  context 'when school manager' do
    let(:user) { build(:school_manager) }

    context 'when manager of setsumeikai school' do
      before do
        user.managed_schools << setsumeikai.school
      end

      it_behaves_like 'fully authorized user'
    end

    context 'when viewer' do
      before do
        user.managed_schools << create(:school)
        create(:setsumeikai_involvement, school: user.managed_schools.first, setsumeikai: setsumeikai)
      end

      it_behaves_like 'viewer'
    end

    context 'when manager of uninvolved school' do
      it_behaves_like 'unauthorized user'
    end
  end

  context 'when statistician' do
    let(:user) { build(:statistician) }

    it_behaves_like 'unauthorized user'
  end

  context 'when customer' do
    let(:user) { build(:customer) }

    it_behaves_like 'unauthorized user'
  end

  context 'when resolving scope' do
    let(:setsumeikais) { create_list(:setsumeikai, 2) }

    it 'resolves admin to all setsumeikais' do
      user = build(:admin)
      expect(Pundit.policy_scope!(user, Setsumeikai)).to eq(setsumeikais)
    end

    it 'resolves area_manager to area setsumeikais' do
      user = create(:area_manager)
      user.managed_areas << create(:area)
      school = create(:school, area: user.managed_areas.first)
      area_setsumeikais = create_list(:setsumeikai, 2, school: school)
      expect(Pundit.policy_scope!(user, Setsumeikai)).to eq(area_setsumeikais)
    end

    it 'resolves school_manager to school setsumeikais' do
      user = create(:school_manager)
      user.managed_schools << create(:school)
      school_setsumeikais = create_list(:setsumeikai, 2, school: user.managed_schools.first)
      expect(Pundit.policy_scope!(user, Setsumeikai)).to eq(school_setsumeikais)
    end

    it 'resolves statistician to all setsumeikais' do
      user = build(:statistician)
      expect(Pundit.policy_scope!(user, Setsumeikai)).to eq(setsumeikais)
    end

    it 'resolves customer to nothing' do
      user = build(:customer)
      expect(Pundit.policy_scope!(user, Setsumeikai)).to eq(Setsumeikai.none)
    end
  end
end
