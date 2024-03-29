# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SurveyPolicy do
  subject(:policy) { described_class.new(user, survey) }

  let(:survey) { build(:survey) }

  context 'when admin' do
    let(:user) { build(:admin) }

    it_behaves_like 'authorized except destroy'
  end

  context 'when area manager' do
    let(:user) { build(:area_manager) }

    it_behaves_like 'viewer'
  end

  context 'when school manager' do
    let(:user) { build(:school_manager) }

    it_behaves_like 'viewer'
  end

  context 'when statistician' do
    let(:user) { build(:statistician) }

    it_behaves_like 'viewer'
  end

  context 'when customer' do
    let(:user) { build(:customer) }

    it_behaves_like 'unauthorized user'
  end

  context 'when resolving scopes' do
    let(:surveys) { create_list(:survey, 3) }

    it 'resolves admin to all surveys' do
      user = build(:admin)
      expect(Pundit.policy_scope!(user, Survey)).to eq(surveys)
    end

    it 'resolves area_manager to all surveys' do
      user = build(:area_manager)
      expect(Pundit.policy_scope!(user, Survey)).to eq(surveys)
    end

    it 'resolves school_manager to all surveys' do
      user = build(:school_manager)
      expect(Pundit.policy_scope!(user, Survey)).to eq(surveys)
    end

    it 'resolves statistician to all surveys' do
      user = build(:statistician)
      expect(Pundit.policy_scope!(user, Survey)).to eq(surveys)
    end
  end
end
