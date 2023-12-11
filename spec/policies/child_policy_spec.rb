# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'staff for ChildPolicy' do
  it { is_expected.to authorize_action(:show) }
  it { is_expected.to authorize_action(:new) }
  it { is_expected.to authorize_action(:edit) }
  it { is_expected.to authorize_action(:create) }
  it { is_expected.to authorize_action(:update) }
  it { is_expected.to authorize_action(:destroy) }
end

describe ChildPolicy do
  subject(:policy) { described_class.new(user, child) }

  let(:child) { build(:child) }

  context 'when admin' do
    let(:user) { build(:admin) }

    it_behaves_like 'staff for ChildPolicy'
  end

  context 'when area_manager' do
    let(:user) { build(:area_manager) }

    it_behaves_like 'staff for ChildPolicy'
  end

  context 'when school_manager' do
    let(:user) { build(:school_manager) }

    it_behaves_like 'staff for ChildPolicy'
  end

  context 'when parent of child' do
    let(:user) { create(:customer) }
    let(:child) { create(:child, parent: user) }

    it { is_expected.to authorize_action(:show) }
    it { is_expected.to authorize_action(:new) }
    it { is_expected.to authorize_action(:edit) }
    it { is_expected.to authorize_action(:create) }
    it { is_expected.to authorize_action(:update) }
    it { is_expected.not_to authorize_action(:destroy) }
  end

  context 'when statistician' do
    let(:user) { build(:statistician) }

    it { is_expected.not_to authorize_action(:show) }
    it { is_expected.not_to authorize_action(:new) }
    it { is_expected.not_to authorize_action(:edit) }
    it { is_expected.not_to authorize_action(:create) }
    it { is_expected.not_to authorize_action(:update) }
    it { is_expected.not_to authorize_action(:destroy) }
  end

  context 'when parent of different child' do
    let(:user) { create(:customer) }

    it { is_expected.not_to authorize_action(:show) }
    it { is_expected.to authorize_action(:new) }
    it { is_expected.not_to authorize_action(:edit) }
    it { is_expected.not_to authorize_action(:create) }
    it { is_expected.not_to authorize_action(:update) }
    it { is_expected.not_to authorize_action(:destroy) }
  end

  context 'when no user' do
    let(:user) { nil }

    it 'raises an error if not authenticated' do
      expect { policy }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  context 'when resolving scopes' do
    let(:children) { create_list(:child, 3) }

    it 'resolves admin to all children' do
      user = build(:admin)
      expect(Pundit.policy_scope!(user, Child.all)).to eq(Child.all)
    end

    it 'resolves area_manager to children of area' do
      user = create(:area_manager)
      user.managed_areas << create(:area)
      area_school = create(:school, area: user.managed_areas.first)
      area_children = create_list(:child, 2, school: area_school)
      expect(Pundit.policy_scope!(user, Child.all)).to eq(area_children)
    end

    it 'resolves school_manager to children of school' do
      user = create(:school_manager)
      user.managed_schools << create(:school)
      school_children = create_list(:child, 2, school: user.managed_schools.first)
      expect(Pundit.policy_scope!(user, Child.all)).to eq(school_children)
    end

    it 'resolves statistician to nothing' do
      user = create(:statistician)
      expect(Pundit.policy_scope!(user, Child.all)).to eq(Child.none)
    end

    it 'resolves parent to nothing' do
      user = create(:customer)
      create_list(:child, 2, parent: user)
      expect(Pundit.policy_scope!(user, Child.all)).to eq(Child.none)
    end
  end
end
