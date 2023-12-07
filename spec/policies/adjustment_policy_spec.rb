# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'staff for AdjustmentPolicy' do
  it { is_expected.to authorize_action(:edit) }
end

describe AdjustmentPolicy do
  subject(:policy) { described_class.new(user, nil) }

  context 'when admin' do
    let(:user) { build(:admin) }

    it_behaves_like 'staff for AdjustmentPolicy'
  end

  context 'when area manager' do
    let(:user) { build(:area_manager) }

    it_behaves_like 'staff for AdjustmentPolicy'
  end

  context 'when school manager' do
    let(:user) { build(:school_manager) }

    it_behaves_like 'staff for AdjustmentPolicy'
  end

  context 'when statistician' do
    let(:user) { build(:statistician) }

    it { is_expected.not_to authorize_action(:edit) }
  end

  context 'when customer' do
    let(:user) { build(:customer) }

    it { is_expected.not_to authorize_action(:edit) }
  end
end
