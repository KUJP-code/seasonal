# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'authorized user for SetsumeikaiPolicy' do
  it { is_expected.to authorize_action(:index) }
  it { is_expected.to authorize_action(:show) }
  it { is_expected.to authorize_action(:new) }
  it { is_expected.to authorize_action(:create) }
  it { is_expected.to authorize_action(:edit) }
  it { is_expected.to authorize_action(:update) }
  it { is_expected.to authorize_action(:destroy) }
end

RSpec.shared_examples 'unauthorized user for SetsumeikaiPolicy' do
  it { is_expected.not_to authorize_action(:show) }
  it { is_expected.not_to authorize_action(:new) }
  it { is_expected.not_to authorize_action(:create) }
  it { is_expected.not_to authorize_action(:edit) }
  it { is_expected.not_to authorize_action(:update) }
  it { is_expected.not_to authorize_action(:destroy) }
end

RSpec.describe SetsumeikaiPolicy do
  subject(:policy) { described_class.new(user, setsumeikai) }

  let(:setsumeikai) { create(:setsumeikai) }

  context 'when admin' do
    let(:user) { build(:admin) }

    it_behaves_like 'authorized user for SetsumeikaiPolicy'
  end

  context 'when manager of setsumeikai area' do
    let(:user) { create(:area_manager) }

    before do
      user.managed_areas << setsumeikai.area
      user.save
    end

    it_behaves_like 'authorized user for SetsumeikaiPolicy'
  end

  context 'when manager of different area' do
    let(:user) { create(:area_manager) }

    it { is_expected.to authorize_action(:index) }

    it_behaves_like 'unauthorized user for SetsumeikaiPolicy'
  end

  context 'when manager of setsumeikai school' do
    let(:user) { create(:school_manager) }

    before do
      user.managed_schools << setsumeikai.school
      user.save
    end

    it_behaves_like 'authorized user for SetsumeikaiPolicy'
  end

  context 'when manager of different school' do
    let(:user) { create(:school_manager) }

    it { is_expected.to authorize_action(:index) }

    it_behaves_like 'unauthorized user for SetsumeikaiPolicy'
  end

  context 'when statistician' do
    let(:user) { create(:statistician) }

    it { is_expected.not_to authorize_action(:index) }

    it_behaves_like 'unauthorized user for SetsumeikaiPolicy'
  end

  context 'when customer' do
    let(:user) { create(:customer) }

    it { is_expected.not_to authorize_action(:index) }

    it_behaves_like 'unauthorized user for SetsumeikaiPolicy'
  end
end
