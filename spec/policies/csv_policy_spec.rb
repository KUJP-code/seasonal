# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'unauthorized user for CsvPolicy' do
  it { is_expected.not_to authorize_action(:index) }
  it { is_expected.not_to authorize_action(:download) }
  it { is_expected.not_to authorize_action(:update) }
  it { is_expected.not_to authorize_action(:upload) }
  it { is_expected.not_to authorize_action(:photo_kids) }
end

RSpec.describe CsvPolicy do
  subject(:policy) { described_class.new(user, nil) }

  context 'when admin' do
    let(:user) { build(:admin) }

    it { is_expected.to authorize_action(:index) }
    it { is_expected.to authorize_action(:download) }
    it { is_expected.to authorize_action(:update) }
    it { is_expected.to authorize_action(:upload) }
    it { is_expected.to authorize_action(:photo_kids) }
  end

  context 'when area manager' do
    let(:user) { build(:area_manager) }

    it_behaves_like 'unauthorized user for CsvPolicy'
  end

  context 'when school manager' do
    let(:user) { build(:school_manager) }

    it_behaves_like 'unauthorized user for CsvPolicy'
  end

  context 'when statistician' do
    let(:user) { build(:statistician) }

    it_behaves_like 'unauthorized user for CsvPolicy'
  end

  context 'when customer' do
    let(:user) { build(:customer) }

    it_behaves_like 'unauthorized user for CsvPolicy'
  end
end
