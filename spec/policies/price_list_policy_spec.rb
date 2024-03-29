# frozen_string_literal: true

require 'rails_helper'

describe PriceListPolicy do
  subject(:policy) { described_class.new(user, price_list) }

  let(:price_list) { build(:member_prices) }

  context 'when admin' do
    let(:user) { build(:admin) }

    it_behaves_like 'fully authorized user'
  end

  context 'when area manager' do
    let(:user) { build(:area_manager) }

    it_behaves_like 'unauthorized user'
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
    let(:price_lists) { create_list(:member_prices, 3) }

    it 'resolves admin to all price lists' do
      user = build(:admin)
      expect(Pundit.policy_scope!(user, PriceList)).to eq(price_lists)
    end

    it 'resolves area_manager to nothing' do
      user = build(:area_manager)
      expect(Pundit.policy_scope!(user, PriceList)).to be_empty
    end

    it 'resolves school_manager to nothing' do
      user = build(:school_manager)
      expect(Pundit.policy_scope!(user, PriceList)).to be_empty
    end

    it 'resolves statistician to nothing' do
      user = build(:statistician)
      expect(Pundit.policy_scope!(user, PriceList)).to be_empty
    end

    it 'resolves customer to nothing' do
      user = build(:customer)
      expect(Pundit.policy_scope!(user, PriceList)).to be_empty
    end
  end
end
