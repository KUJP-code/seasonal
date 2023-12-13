# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'staff for UserPolicy' do
  it { is_expected.to authorize_action(:index) }
  it { is_expected.to authorize_action(:show) }
  it { is_expected.to authorize_action(:new) }
  it { is_expected.to authorize_action(:create) }
  it { is_expected.to authorize_action(:edit) }
  it { is_expected.to authorize_action(:update) }
  it { is_expected.to authorize_action(:merge_children) }
end

RSpec.shared_examples 'customer for UserPolicy' do
  it { is_expected.not_to authorize_action(:index) }
  it { is_expected.not_to authorize_action(:show) }
  it { is_expected.not_to authorize_action(:new) }
  it { is_expected.not_to authorize_action(:create) }
  it { is_expected.not_to authorize_action(:edit) }
  it { is_expected.not_to authorize_action(:update) }
  it { is_expected.not_to authorize_action(:merge_children) }
end

RSpec.shared_examples 'non-admin staff for UserPolicy' do
  it 'cannot view admin profiles' do
    record = create(:admin)
    expect(policy).not_to authorize_action(:show)
  end

  it 'cannot view area manager profiles' do
    record = create(:area_manager)
    expect(policy).not_to authorize_action(:show)
  end

  it 'cannot view school manager profiles' do
    record = create(:school_manager)
    expect(policy).not_to authorize_action(:show)
  end
end

RSpec.describe UserPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { create(:customer) }

  context 'when admin' do
    let(:user) { create(:admin) }

    it 'can view admin profiles' do
      record = create(:admin)
      expect(policy).to authorize_action(:show)
    end

    it 'can view area manager profiles' do
      record = create(:area_manager)
      expect(policy).to authorize_action(:show)
    end

    it 'cannot view school manager profiles' do
      record = create(:school_manager)
      expect(policy).to authorize_action(:show)
    end

    it_behaves_like 'staff for UserPolicy'
  end

  context 'when area manager' do
    let(:user) { create(:area_manager) }

    it_behaves_like 'staff for UserPolicy'
    it_behaves_like 'non-admin staff for UserPolicy'
  end

  context 'when school manager' do
    let(:user) { create(:school_manager) }

    it_behaves_like 'staff for UserPolicy'
    it_behaves_like 'non-admin staff for UserPolicy'
  end

  context 'when statistician' do
    let(:user) { create(:statistician) }

    context 'when viewing own profile' do
      let(:record) { user }

      it 'can view their own profile' do
        expect(policy).to authorize_action(:show)
      end
    end

    it_behaves_like 'customer for UserPolicy'
  end

  context 'when customer' do
    let(:user) { create(:customer) }

    context 'when viewing own profile' do
      let(:record) { user }

      it 'can view their own profile' do
        expect(policy).to authorize_action(:show)
      end
    end

    it_behaves_like 'customer for UserPolicy'
  end

  context 'when resolving scopes' do
    let(:users) { create_list(:customer, 3) }

    it 'resolves admin to all users' do
      user = build(:admin)
      expect(Pundit.policy_scope!(user, User.all)).to eq(users)
    end

    it 'resolves area_manager to area users' do
      user = create(:area_manager)
      user.managed_areas << create(:area)
      school = create(:school, area: user.managed_areas.first)
      area_users = create_list(
        :customer, 2,
        children: [create(:internal_child, school: school)]
      )
      expect(Pundit.policy_scope!(user, User.all)).to eq(area_users)
    end

    it 'resolves school_manager to school users' do
      user = create(:school_manager)
      user.managed_schools << create(:school)
      school_users = create_list(
        :customer, 2,
        children: [create(:internal_child, school: user.managed_school)]
      )
      expect(Pundit.policy_scope!(user, User.all)).to eq(school_users)
    end

    it 'resolves statistician to nothing' do
      user = create(:statistician)
      expect(Pundit.policy_scope!(user, User.all)).to eq(User.none)
    end

    it 'resolves parent to nothing' do
      user = create(:customer)
      expect(Pundit.policy_scope!(user, User.all)).to eq(User.none)
    end
  end
end
