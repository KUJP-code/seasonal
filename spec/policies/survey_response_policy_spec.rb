# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'creator for SurveyResponsePolicy' do
  it { is_expected.to authorize_action(:create) }
end

RSpec.shared_examples 'commenter for SurveyResponsePolicy' do
  it { is_expected.not_to authorize_action(:create) }
  it { is_expected.to authorize_action(:update) }
end

RSpec.shared_examples 'unauthorized user for SurveyResponsePolicy' do
  it { is_expected.not_to authorize_action(:create) }
  it { is_expected.not_to authorize_action(:update) }
end

RSpec.describe SurveyResponsePolicy do
  subject(:policy) { described_class.new(user, survey_response) }

  let(:survey_response) { create(:survey_response) }

  context 'when admin' do
    let(:user) { build(:admin) }

    it { is_expected.to authorize_action(:update) }

    it_behaves_like 'creator for SurveyResponsePolicy'
  end

  context 'when manager of child area' do
    let(:user) { create(:area_manager) }

    before do
      user.managed_areas << survey_response.child.area
      user.save
    end

    it_behaves_like 'commenter for SurveyResponsePolicy'
  end

  context 'when manager of different area' do
    let(:user) { create(:area_manager) }

    it_behaves_like 'unauthorized user for SurveyResponsePolicy'
  end

  context 'when manager of child school' do
    let(:user) { create(:school_manager) }

    before do
      user.managed_schools << survey_response.child.school
      user.save
    end

    it_behaves_like 'commenter for SurveyResponsePolicy'
  end

  context 'when manager of different school' do
    let(:user) { create(:school_manager) }

    before do
      user.managed_schools << create(:school)
    end

    it_behaves_like 'unauthorized user for SurveyResponsePolicy'
  end

  context 'when statistician' do
    let(:user) { create(:statistician) }

    it_behaves_like 'unauthorized user for SurveyResponsePolicy'
  end

  context 'when parent of child' do
    let(:user) { create(:customer) }

    before do
      user.children << survey_response.child
      user.save
    end

    it { is_expected.not_to authorize_action(:update) }

    it_behaves_like 'creator for SurveyResponsePolicy'
  end

  context 'when parent of different child' do
    let(:user) { create(:customer) }

    it_behaves_like 'unauthorized user for SurveyResponsePolicy'
  end

  context 'when resolving scopes' do
    let(:survey_responses) { create_list(:survey_response, 3) }

    it 'resolves admin to all survey responses' do
      user = build(:admin)
      expect(Pundit.policy_scope!(user, SurveyResponse)).to eq(survey_responses)
    end

    it 'resolves area_manager to area survey responses' do
      user = create(:area_manager)
      user.managed_areas << create(:area)
      school = create(:school, area: user.managed_areas.first)
      area_responses = create_list(
        :survey_response, 2,
        child: create(:child, school: school)
      )
      expect(Pundit.policy_scope!(user, SurveyResponse)).to eq(area_responses)
    end

    it 'resolves school_manager to school survey responses' do
      user = create(:school_manager)
      user.managed_schools << create(:school)
      school_responses = create_list(
        :survey_response, 2,
        child: create(:child, school: user.managed_schools.first)
      )
      expect(Pundit.policy_scope!(user, SurveyResponse)).to eq(school_responses)
    end

    it 'resolves statistician to all survey responses' do
      user = create(:statistician)
      expect(Pundit.policy_scope!(user, SurveyResponse)).to eq(SurveyResponse.all)
    end

    it 'resolves customer to nothing' do
      user = create(:customer)
      expect(Pundit.policy_scope!(user, SurveyResponse)).to eq(SurveyResponse.none)
    end
  end
end
