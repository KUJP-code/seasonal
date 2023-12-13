# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'creator for SurveyResponsePolicy request' do
  it 'allows survey response to be created' do
    response_attributes = attributes_for(
      :survey_response,
      child_id: user.children.empty? ? create(:child).id : user.children.first.id,
      survey_id: survey_response.survey_id
    )
    expect do
      post '/survey_responses',
           params: { survey_response: response_attributes }
    end
      .to change(SurveyResponse, :count).by(1)
  end
end

RSpec.shared_examples 'commenter for SurveyResponsePolicy request' do
  it 'does not allow response creation' do
    response_attributes = attributes_for(
      :survey_response,
      child_id: create(:child).id,
      survey_id: survey_response.survey_id
    )
    expect do
      post '/survey_responses',
           params: { survey_response: response_attributes }
    end
      .not_to change(SurveyResponse, :count)
  end

  it 'allows commenting on responses' do
    response_attributes = attributes_for(:survey_response, comment: 'test')
    patch "/survey_responses/#{survey_response.id}",
          params: { survey_response: response_attributes }
    expect(survey_response.reload.comment).to eq('test')
  end
end

RSpec.shared_examples 'unauthorized user for SurveyResponsePolicy request' do
  it 'does not allow response creation' do
    response_attributes = attributes_for(
      :survey_response,
      child_id: create(:child).id,
      survey_id: survey_response.survey_id
    )
    expect do
      post '/survey_responses',
           params: { survey_response: response_attributes }
    end
      .not_to change(SurveyResponse, :count)
  end

  it 'does not allow commenting on responses' do
    response_attributes = attributes_for(:survey_response, comment: 'test')
    patch "/survey_responses/#{survey_response.id}",
          params: { survey_response: response_attributes }
    expect(survey_response.reload.comment).to be_nil
  end
end

RSpec.describe SurveyResponse do
  let(:survey_response) { create(:survey_response) }

  before do
    sign_in user
  end

  after do
    sign_out user
  end

  context 'when admin' do
    let(:user) { create(:admin) }

    it 'allows commenting on responses' do
      response_attributes = attributes_for(:survey_response, comment: 'test')
      patch "/survey_responses/#{survey_response.id}",
            params: { survey_response: response_attributes }
      expect(survey_response.reload.comment).to eq('test')
    end

    it_behaves_like 'creator for SurveyResponsePolicy request'
  end

  context 'when manager of child area' do
    let(:user) { create(:area_manager) }

    before do
      user.managed_areas << survey_response.child.area
      user.save
    end

    it_behaves_like 'commenter for SurveyResponsePolicy request'
  end

  context 'when manager of different area' do
    let(:user) { create(:area_manager) }

    it_behaves_like 'unauthorized user for SurveyResponsePolicy request'
  end

  context 'when manager of child school' do
    let(:user) { create(:school_manager) }

    before do
      user.managed_schools << survey_response.child.school
      user.save
    end

    it_behaves_like 'commenter for SurveyResponsePolicy request'
  end

  context 'when statistician' do
    let(:user) { create(:statistician) }

    it_behaves_like 'unauthorized user for SurveyResponsePolicy request'
  end

  context 'when manager of different school' do
    let(:user) { create(:school_manager) }

    before do
      user.managed_schools << create(:school)
    end

    it_behaves_like 'unauthorized user for SurveyResponsePolicy request'
  end

  context 'when parent of child' do
    let(:user) { create(:customer) }

    before do
      user.children << survey_response.child
      user.save
    end

    it 'cannot comment on response' do
      response_attributes = attributes_for(:survey_response, comment: 'test')
      patch "/survey_responses/#{survey_response.id}",
            params: { survey_response: response_attributes }
      expect(survey_response.reload.comment).to be_nil
    end

    it_behaves_like 'creator for SurveyResponsePolicy request'
  end

  context 'when parent of different child' do
    let(:user) { create(:customer) }

    it_behaves_like 'unauthorized user for SurveyResponsePolicy request'
  end
end
