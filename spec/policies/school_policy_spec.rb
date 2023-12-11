# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'manager of school for SchoolPolicy' do
  it { is_expected.to authorize_action(:show) }
  it { is_expected.to authorize_action(:edit) }
  it { is_expected.to authorize_action(:update) }
end

RSpec.shared_examples 'unauthorized user for SchoolPolicy' do
  it { is_expected.not_to authorize_action(:show) }
  it { is_expected.not_to authorize_action(:create) }
  it { is_expected.not_to authorize_action(:edit) }
  it { is_expected.not_to authorize_action(:update) }
end

RSpec.describe SchoolPolicy do
  subject(:policy) { described_class.new(user, school) }

  let(:school) { create(:school) }

  context 'when admin' do
    let(:user) { build(:admin) }

    it { is_expected.to authorize_action(:new) }
    it { is_expected.to authorize_action(:create) }

    it_behaves_like 'manager of school for SchoolPolicy'
  end

  context "when manager of school's area" do
    let(:user) { create(:area_manager) }

    before do
      user.managed_areas << school.area
      user.save
    end

    it_behaves_like 'manager of school for SchoolPolicy'
  end

  context 'when manager of different area' do
    let(:user) { create(:area_manager) }

    it_behaves_like 'unauthorized user for SchoolPolicy'
  end

  context 'when school manager of school' do
    let(:user) { create(:school_manager) }

    before do
      user.managed_schools << school
      user.save
    end

    it_behaves_like 'manager of school for SchoolPolicy'
  end

  context 'when school unauthorized user' do
    let(:user) { create(:school_manager) }

    it_behaves_like 'unauthorized user for SchoolPolicy'
  end

  context 'when statistician' do
    let(:user) { create(:statistician) }

    it_behaves_like 'unauthorized user for SchoolPolicy'
  end

  context 'when customer' do
    let(:user) { create(:customer) }

    it_behaves_like 'unauthorized user for SchoolPolicy'
  end

  context 'when resolving scope' do
    let(:schools) { create_list(:school, 3) }

    it 'resolves admin to all non-test schools' do
      user = create(:admin)
      expect(Pundit.policy_scope!(user, School)).to eq(schools)
    end

    it 'resolves area_manager to area schools' do
      user = create(:area_manager)
      user.managed_areas << create(:area)
      area_schools = create_list(:school, 2, area: user.managed_areas.first)
      expect(Pundit.policy_scope!(user, School)).to eq(area_schools)
    end

    it 'resolves school_manager to school' do
      user = create(:school_manager)
      user.managed_schools << create(:school)
      expect(Pundit.policy_scope!(user, School)).to eq(user.managed_schools)
    end

    it 'resolves statistician to all schools' do
      user = create(:statistician)
      expect(Pundit.policy_scope!(user, School)).to eq(schools)
    end

    it 'resolves customer to nothing' do
      user = create(:customer)
      expect(Pundit.policy_scope!(user, School)).to be_empty
    end
  end
end
