# frozen_string_literal: true

require 'rails_helper'
require 'faker/japanese'
Faker::Config.locale = :ja
require Rails.root.join('spec/support/survey_helpers').to_s
RSpec.configure do |c|
  c.include SurveyHelpers
end

describe Survey do
  context 'with #criteria_match' do
    it 'returns false if all criteria blank' do
      criterialess_survey = create(:criterialess_survey)

      expect(criterialess_survey.criteria_match?(create(:child))).to be false
    end

    it 'returns false if child has responded to the survey' do
      child = create(:child, category: :external)
      answered_survey = create(:survey, criteria: { 'category' => 'external' })
      create(:survey_response, survey: answered_survey, child: child)

      expect(answered_survey.criteria_match?(child)).to be false
    end

    it 'returns false if sibling has responded to the survey' do
      parent = create(:user)
      children = create_list(:child, 2, parent: parent, category: :external)
      answered_survey = create(:survey, criteria: { 'category' => 'external' })
      create(:survey_response, survey: answered_survey, child: children.first)

      expect(answered_survey.criteria_match?(children.last)).to be false
    end

    it 'returns true when random enum criteria & it matches' do
      criteria = set_random_enum_criteria
      child = create(:child)
      single_criteria_survey = set_single_criteria(child, criteria)

      expect(single_criteria_survey.criteria_match?(child)).to be true
    end

    it 'returns true when random string criteria & it matches' do
      criteria = set_random_string_criteria
      child = create(:child)
      single_criteria_survey = set_single_criteria(child, criteria)

      expect(single_criteria_survey.criteria_match?(child)).to be true
    end

    it 'returns true when SSID criteria & it matches' do
      criteria = { 'ssid' => Faker::Number.number(digits: 10) }
      single_criteria_survey = create(:active_survey, criteria: criteria)
      child = create(:child, ssid: criteria['ssid'])

      expect(single_criteria_survey.criteria_match?(child)).to be true
    end

    it 'returns true when date criteria & it matches' do
      criteria = {
        'birthday' => Faker::Date.between(from: 10.years.ago, to: 6.years.ago)
      }
      single_criteria_survey = create(:active_survey, criteria: criteria)
      child = create(:child, birthday: criteria['birthday'])

      expect(single_criteria_survey.criteria_match?(child)).to be true
    end

    it 'returns true when random boolean criteria & it matches' do
      criteria = set_random_boolean_criteria
      child = create(:child)
      single_criteria_survey = set_single_criteria(child, criteria)

      expect(single_criteria_survey.criteria_match?(child)).to be true
    end
  end
end
