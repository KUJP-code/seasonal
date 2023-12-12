# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'manager of setsumeikai school for SetsumeikaiPolicy' do
  it { is_expected.to authorize_action(:index) }
  it { is_expected.to authorize_action(:show) }
  it { is_expected.to authorize_action(:new) }
  it { is_expected.to authorize_action(:create) }
  it { is_expected.to authorize_action(:edit) }
  it { is_expected.to authorize_action(:update) }
  it { is_expected.to authorize_action(:destroy) }
end

RSpec.shared_examples 'manager of involved school' do
  it { is_expected.to authorize_action(:index) }
  it { is_expected.to authorize_action(:show) }
  it { is_expected.not_to authorize_action(:new) }
  it { is_expected.not_to authorize_action(:create) }
  it { is_expected.not_to authorize_action(:edit) }
  it { is_expected.not_to authorize_action(:update) }
  it { is_expected.not_to authorize_action(:destroy) }
end

RSpec.shared_examples 'unauthorized user for SetsumeikaiPolicy' do
  it { is_expected.not_to authorize_action(:show) }
  it { is_expected.not_to authorize_action(:new) }
  it { is_expected.not_to authorize_action(:create) }
  it { is_expected.not_to authorize_action(:edit) }
  it { is_expected.not_to authorize_action(:update) }
  it { is_expected.not_to authorize_action(:destroy) }
end

RSpec.describe SetsumeikaiPolicy do
  subject(:policy) { described_class.new(user, setsumeikai) }

  let(:setsumeikai) { create(:setsumeikai) }

  context 'when admin' do
    let(:user) { build(:admin) }

    it_behaves_like 'manager of setsumeikai school for SetsumeikaiPolicy'
  end

  context 'when manager of setsumeikai area' do
    let(:user) { create(:area_manager) }

    before do
      user.managed_areas << setsumeikai.area
      user.save
    end

    it_behaves_like 'manager of setsumeikai school for SetsumeikaiPolicy'
  end

  context 'when area manager of involved school' do
    let(:user) { create(:area_manager) }

    before do
      user.managed_areas << create(:area)
      school = create(:school, area: user.managed_areas.first)
      create(:setsumeikai_involvement, school: school, setsumeikai: setsumeikai)
    end

    it_behaves_like 'manager of involved school'
  end

  context 'when area manager of uninvolved school' do
    let(:user) { create(:area_manager) }

    it { is_expected.to authorize_action(:index) }

    it_behaves_like 'unauthorized user for SetsumeikaiPolicy'
  end

  context 'when manager of setsumeikai school' do
    let(:user) { create(:school_manager) }

    before do
      user.managed_schools << setsumeikai.school
      user.save
    end

    it_behaves_like 'manager of setsumeikai school for SetsumeikaiPolicy'
  end

  context 'when manager of involved school' do
    let(:user) { create(:school_manager) }

    before do
      user.managed_schools << create(:school)
      create(:setsumeikai_involvement, school: user.managed_schools.first, setsumeikai: setsumeikai)
    end

    it_behaves_like 'manager of involved school'
  end

  context 'when manager of uninvolved school' do
    let(:user) { create(:school_manager) }

    it { is_expected.to authorize_action(:index) }

    it_behaves_like 'unauthorized user for SetsumeikaiPolicy'
  end

  context 'when statistician' do
    let(:user) { create(:statistician) }

    it { is_expected.not_to authorize_action(:index) }

    it_behaves_like 'unauthorized user for SetsumeikaiPolicy'
  end

  context 'when customer' do
    let(:user) { create(:customer) }

    it { is_expected.not_to authorize_action(:index) }

    it_behaves_like 'unauthorized user for SetsumeikaiPolicy'
  end

  context 'when resolving scope' do
    let(:setsumeikais) { create_list(:setsumeikai, 3) }

    it 'resolves admin to all setsumeikais' do
      user = create(:admin)
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

    it 'resolves statistician to nothing' do
      user = create(:statistician)
      expect(Pundit.policy_scope!(user, Setsumeikai)).to eq(Setsumeikai.none)
    end

    it 'resolves customer to nothing' do
      user = create(:customer)
      expect(Pundit.policy_scope!(user, Setsumeikai)).to eq(Setsumeikai.none)
    end
  end
end
