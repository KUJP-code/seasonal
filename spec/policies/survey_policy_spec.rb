# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'viewer for SurveyPolicy' do
  it { is_expected.to authorize_action(:index) }
  it { is_expected.to authorize_action(:show) }
  it { is_expected.not_to authorize_action(:new) }
  it { is_expected.not_to authorize_action(:create) }
  it { is_expected.not_to authorize_action(:edit) }
  it { is_expected.not_to authorize_action(:update) }
end

RSpec.shared_examples 'unauthorized user for SurveyPolicy' do
  it { is_expected.not_to authorize_action(:index) }
  it { is_expected.not_to authorize_action(:show) }
  it { is_expected.not_to authorize_action(:new) }
  it { is_expected.not_to authorize_action(:create) }
  it { is_expected.not_to authorize_action(:edit) }
  it { is_expected.not_to authorize_action(:update) }
end

RSpec.describe SurveyPolicy do
  subject(:policy) { described_class.new(user, survey) }

  let(:survey) { create(:survey) }

  context 'when admin' do
    let(:user) { create(:admin) }

    it { is_expected.to authorize_action(:index) }
    it { is_expected.to authorize_action(:show) }
    it { is_expected.to authorize_action(:new) }
    it { is_expected.to authorize_action(:create) }
    it { is_expected.to authorize_action(:edit) }
    it { is_expected.to authorize_action(:update) }
  end

  context 'when area manager' do
    let(:user) { create(:area_manager) }

    it_behaves_like 'viewer for SurveyPolicy'
  end

  context 'when school manager' do
    let(:user) { create(:school_manager) }

    it_behaves_like 'viewer for SurveyPolicy'
  end

  context 'when statistician' do
    let(:user) { create(:statistician) }

    it_behaves_like 'viewer for SurveyPolicy'
  end

  context 'when customer' do
    let(:user) { create(:customer) }

    it_behaves_like 'unauthorized user for SurveyPolicy'
  end
end
