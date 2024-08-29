# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StaffUserPolicy do
  subject(:policy) { described_class.new(user, staff_user) }

  let(:staff_user) { build(:user, :admin) }

  context 'when admin' do
    let(:user) { build(:admin) }

    context 'when staff_user is admin' do
      let(:staff_user) { build(:user, :admin) }

      it_behaves_like 'authorized except destroy'
    end

    context 'when staff user is area manager' do
      let(:staff_user) { build(:user, :area_manager) }

      it_behaves_like 'fully authorized user'
    end

    context 'when staff user is school manager' do
      let(:staff_user) { build(:user, :school_manager) }

      it_behaves_like 'fully authorized user'
    end

    context 'when staff user is statistician' do
      let(:staff_user) { build(:user, :statistician) }

      it_behaves_like 'fully authorized user'
    end
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
end
