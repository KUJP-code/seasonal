# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'unrestricted viewer for ChartPolicy' do
  it { is_expected.to authorize_action(:index) }
  it { is_expected.to authorize_action(:show) }
end

RSpec.shared_examples 'school manager for ChartPolicy' do
  it { is_expected.not_to authorize_action(:index) }
  it { is_expected.to authorize_action(:show) }
end

RSpec.shared_examples 'unauthorized user for ChartPolicy' do
  it { is_expected.not_to authorize_action(:index) }
  it { is_expected.not_to authorize_action(:show) }
end

RSpec.describe ChartPolicy do
  subject(:policy) { described_class.new(user, nil) }

  context 'when admin' do
    let(:user) { build(:admin) }

    it_behaves_like 'unrestricted viewer for ChartPolicy'
  end

  context 'when area manager' do
    let(:user) { build(:area_manager) }

    it_behaves_like 'unrestricted viewer for ChartPolicy'
  end

  context 'when school manager' do
    let(:user) { build(:school_manager) }

    it_behaves_like 'school manager for ChartPolicy'
  end

  context 'when statistician' do
    let(:user) { build(:statistician) }

    it_behaves_like 'unrestricted viewer for ChartPolicy'
  end

  context 'when customer' do
    let(:user) { build(:customer) }

    it_behaves_like 'unauthorized user for ChartPolicy'
  end
end
