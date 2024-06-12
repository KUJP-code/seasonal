# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StaffUserPolicy do
  subject(:policy) { described_class.new(user, staff_user) }

  let(:role) { %i[area_manager school_manager statistician].sample }
  let(:staff_user) { build(:user, role:) }

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
end
