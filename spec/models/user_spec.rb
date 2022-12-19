# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User' do
  let(:valid_user) { build(:user) }
  let(:user) { create(:user) }

  context 'when valid' do
    it 'saves the User' do
      saves = valid_user.save
      expect(saves).to be true
    end

    it 'role is customer by default' do
      role = user.role
      expect(role).to eq 'customer'
    end
  end

  context 'when role is specified' do
    it 'sets role as customer' do
      role = create(:customer_user).role
      expect(role).to eq 'customer'
    end

    it 'sets role as school manager' do
      role = create(:sm_user).role
      expect(role).to eq 'school_manager'
    end

    it 'sets role as area manager' do
      role = create(:am_user).role
      expect(role).to eq 'area_manager'
    end

    it 'sets role as admin' do
      role = create(:admin_user).role
      expect(role).to eq 'admin'
    end

    it 'can be confirmed with customer?' do
      confirmable = create(:customer_user).customer?
      expect(confirmable).to be true
    end

    it 'can be confirmed with school manager' do
      confirmable = create(:sm_user).school_manager?
      expect(confirmable).to be true
    end

    it 'can be confirmed with area manager' do
      confirmable = create(:am_user).area_manager?
      expect(confirmable).to be true
    end

    it 'can be confirmed with admin' do
      confirmable = create(:admin_user).admin?
      expect(confirmable).to be true
    end
  end
end
