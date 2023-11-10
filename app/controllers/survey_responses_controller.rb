# frozen_string_literal: true

class SurveyResponsesController < ApplicationController
  def index
    @survey_responses = policy_scope(SurveyResponse)
  end

  def create
    @survey_response = SurveyResponse.new(survey_response_params)

    if @survey_response.save
      redirect_to @survey_response,
                  notice: t('.response_appreciated')
    else
      redirect_to '/', alert: t('.unable_to_process')
    end
  end

  private

  def survey_response_params
    params.require(:survey_response).permit(
      :id, :answers, :child_id, :survey_id
    )
  end
end
