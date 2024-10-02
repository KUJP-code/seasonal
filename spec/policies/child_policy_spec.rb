# frozen_string_literal: true

require 'rails_helper'

describe ChildPolicy do
  subject(:policy) { described_class.new(user, child) }

  let(:child) { build(:child) }

  context 'when admin' do
    let(:user) { build(:admin) }

    it_behaves_like 'fully authorized user'
    it { is_expected.to authorize_action(:attended_seasonal) }
  end

  context 'when area_manager' do
    let(:user) { build(:area_manager) }

    it_behaves_like 'fully authorized user'
    it { is_expected.not_to authorize_action(:attended_seasonal) }
  end

  context 'when school_manager' do
    let(:user) { build(:school_manager) }

    it_behaves_like 'fully authorized user'
    it { is_expected.not_to authorize_action(:attended_seasonal) }
  end

  context 'when parent of child' do
    let(:user) { create(:customer) }
    let(:child) { create(:child, parent: user) }

    it_behaves_like 'authorized except destroy'
    it { is_expected.not_to authorize_action(:attended_seasonal) }
  end

  context 'when statistician' do
    let(:user) { build(:statistician) }

    it_behaves_like 'unauthorized user'
    it { is_expected.not_to authorize_action(:attended_seasonal) }
  end

  context 'when not parent of child' do
    let(:user) { build(:customer) }

    it_behaves_like 'only authorized for new'
    it { is_expected.not_to authorize_action(:attended_seasonal) }
  end

  context 'when resolving scopes' do
    let(:children) { create_list(:child, 3) }

    it 'resolves admin to all children' do
      user = build(:admin)
      expect(Pundit.policy_scope!(user, Child)).to eq(Child.all)
    end

    it 'resolves area_manager to children of area' do
      user = create(:area_manager)
      user.managed_areas << create(:area)
      area_school = create(:school, area: user.managed_areas.first)
      area_children = create_list(:child, 2, school: area_school)
      expect(Pundit.policy_scope!(user, Child)).to eq(area_children)
    end

    it 'resolves school_manager to children of school' do
      user = create(:school_manager)
      user.managed_schools << create(:school)
      school_children = create_list(:child, 2, school: user.managed_schools.first)
      expect(Pundit.policy_scope!(user, Child)).to eq(school_children)
    end

    it 'resolves statistician to nothing' do
      user = create(:statistician)
      expect(Pundit.policy_scope!(user, Child)).to eq(Child.none)
    end

    it 'resolves parent to their children' do
      user = create(:customer)
      kids = create_list(:child, 2, parent: user)
      expect(Pundit.policy_scope!(user, Child)).to eq(kids)
    end
  end
end
