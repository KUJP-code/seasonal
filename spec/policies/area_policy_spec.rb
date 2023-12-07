# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'viewer for AreaPolicy' do
  it { is_expected.to authorize_action(:index) }
  it { is_expected.to authorize_action(:show) }
end

RSpec.shared_examples 'unauthorized user for AreaPolicy' do
  it { is_expected.not_to authorize_action(:index) }
  it { is_expected.not_to authorize_action(:show) }
  it { is_expected.not_to authorize_action(:new) }
  it { is_expected.not_to authorize_action(:create) }
  it { is_expected.not_to authorize_action(:edit) }
  it { is_expected.not_to authorize_action(:update) }
  it { is_expected.not_to authorize_action(:destroy) }
end

describe AreaPolicy do
  subject(:policy) { described_class.new(user, area) }

  let(:area) { build(:area) }

  context 'when admin' do
    let(:user) { build(:admin) }

    it_behaves_like 'viewer for AreaPolicy'
    it { is_expected.to authorize_action(:new) }
    it { is_expected.to authorize_action(:create) }
    it { is_expected.to authorize_action(:edit) }
    it { is_expected.to authorize_action(:update) }
    it { is_expected.not_to authorize_action(:destroy) }
  end

  context 'when manager of area' do
    let(:user) { build(:area_manager) }

    before do
      user.managed_areas << area
    end

    it_behaves_like 'viewer for AreaPolicy'
  end

  context 'when manager of different area' do
    let(:user) { build(:area_manager) }

    it { is_expected.to authorize_action(:index) }
    it { is_expected.not_to authorize_action(:show) }
    it { is_expected.not_to authorize_action(:new) }
    it { is_expected.not_to authorize_action(:create) }
    it { is_expected.not_to authorize_action(:edit) }
    it { is_expected.not_to authorize_action(:update) }
    it { is_expected.not_to authorize_action(:destroy) }
  end

  context 'when school manager' do
    let(:user) { build(:school_manager) }

    it_behaves_like 'unauthorized user for AreaPolicy'
  end

  context 'when statistician' do
    let(:user) { build(:statistician) }

    it_behaves_like 'unauthorized user for AreaPolicy'
  end

  context 'when customer' do
    let(:user) { build(:customer) }

    it_behaves_like 'unauthorized user for AreaPolicy'
  end
end
