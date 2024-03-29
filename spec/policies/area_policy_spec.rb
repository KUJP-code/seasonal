# frozen_string_literal: true

require 'rails_helper'

describe AreaPolicy do
  subject(:policy) { described_class.new(user, area) }

  let(:area) { build(:area) }

  context 'when admin' do
    let(:user) { build(:admin) }

    it_behaves_like 'authorized except destroy'
  end

  context 'when area manager' do
    context 'when manager of area' do
      let(:user) { create(:area_manager) }

      before do
        user.managed_areas << area
      end

      it_behaves_like 'viewer'
    end

    context 'when manager of different area' do
      let(:user) { build(:area_manager) }

      it_behaves_like 'unauthorized user'
    end
  end

  context 'when school manager' do
    let(:user) { build(:school_manager) }

    it_behaves_like 'unauthorized user'
  end

  context 'when statistician' do
    let(:user) { build(:statistician) }

    it_behaves_like 'unauthorized user'
  end

  context 'when customer' do
    let(:user) { build(:customer) }

    it_behaves_like 'unauthorized user'
  end

  context 'when resolving scopes' do
    let(:areas) { create_list(:area, 3) }

    it 'resolves admin to all areas' do
      user = build(:admin)
      expect(Pundit.policy_scope!(user, Area)).to eq(Area.all)
    end

    it 'resolves area_manager to areas of manager' do
      user = create(:area_manager)
      managed_area = create(:area)
      user.managed_areas << managed_area
      expect(Pundit.policy_scope!(user, Area)).to eq([managed_area])
    end

    it 'resolves school_manager to nothing' do
      user = create(:school_manager)
      expect(Pundit.policy_scope!(user, Area)).to eq(Area.none)
    end

    it 'resolves statistician to nothing' do
      user = build(:statistician)
      expect(Pundit.policy_scope!(user, Area)).to eq(Area.none)
    end

    it 'resolves customer to nothing' do
      user = build(:customer)
      expect(Pundit.policy_scope!(user, Area)).to eq(Area.none)
    end
  end
end
