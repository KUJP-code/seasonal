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
  context 'when viewing admin profile' do
    let(:record) { create(:admin) }

    it 'cannot view admin profiles' do
      expect(policy).not_to authorize_action(:show)
    end
  end

  context 'when viewing area manager profile' do
    let(:record) { create(:area_manager) }

    it 'cannot view area manager profiles' do
      expect(policy).not_to authorize_action(:show)
    end
  end

  context 'when viewing school manager profile' do
    let(:record) { create(:school_manager) }

    it 'cannot view school manager profiles' do
      expect(policy).not_to authorize_action(:show)
    end
  end
end

RSpec.shared_examples 'Nacrissus' do
  context 'when viewing own profile' do
    let(:record) { user }

    it 'can view their own profile' do
      expect(policy).to authorize_action(:show)
    end
  end
end

RSpec.describe UserPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { create(:customer) }

  context 'when admin' do
    let(:user) { create(:admin) }

    context 'when viewing other admin profile' do
      let(:record) { create(:admin) }

      it 'can view admin profiles' do
        expect(policy).to authorize_action(:show)
      end
    end

    context 'when viewing area manager profile' do
      let(:record) { create(:area_manager) }

      it 'can view area manager profiles' do
        expect(policy).to authorize_action(:show)
      end
    end

    context 'when viewing school manager profile' do
      let(:record) { create(:school_manager) }

      it 'cannot view school manager profiles' do
        expect(policy).to authorize_action(:show)
      end
    end

    it_behaves_like 'staff for UserPolicy'
    it_behaves_like 'Nacrissus'
  end

  context 'when area manager' do
    let(:user) { create(:area_manager) }

    it_behaves_like 'staff for UserPolicy'
    it_behaves_like 'non-admin staff for UserPolicy'
    it_behaves_like 'Nacrissus'

    context 'when viewing profile of SM in their area' do
      let(:record) { create(:school_manager, managed_schools: [create(:school)]) }

      before do
        user.managed_areas << record.managed_school.area
        user.save
      end

      it { is_expected.to authorize_action(:show) }
    end
  end

  context 'when school manager' do
    let(:user) { create(:school_manager) }

    it_behaves_like 'staff for UserPolicy'
    it_behaves_like 'non-admin staff for UserPolicy'
    it_behaves_like 'Nacrissus'
  end

  context 'when statistician' do
    let(:user) { create(:statistician) }

    it_behaves_like 'customer for UserPolicy'
    it_behaves_like 'Nacrissus'
  end

  context 'when customer' do
    let(:user) { create(:customer) }

    it_behaves_like 'customer for UserPolicy'
    it_behaves_like 'Nacrissus'
  end

  context 'when resolving scopes' do
    let(:users) { create_list(:customer, 3) }

    it 'resolves admin to all users' do
      user = build(:admin)
      expect(Pundit.policy_scope!(user, User.all)).to eq(users)
    end

    it 'resolves area_manager to area parents' do
      user = create(:area_manager)
      user.managed_areas << create(:area)
      school = create(:school, area: user.managed_areas.first)
      area_parent = create(:customer, children: [create(:internal_child, school: school)])
      expect(Pundit.policy_scope!(user, User.all)).to contain_exactly(area_parent)
    end

    it 'resolves school_manager to school parents' do
      user = create(:school_manager)
      user.managed_schools << create(:school)
      school_parent = create(
        :customer,
        children: [create(:internal_child, school: user.managed_school)]
      )
      expect(Pundit.policy_scope!(user, User.all)).to contain_exactly(school_parent)
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
