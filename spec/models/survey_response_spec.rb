# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SurveyResponse do
  it 'has a valid factory' do
    expect(build(:survey_response)).to be_valid
  end

  it 'must have an answer' do
    expect(build(:survey_response, answers: [])).not_to be_valid
  end
end
