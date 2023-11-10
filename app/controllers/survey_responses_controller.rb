# frozen_string_literal: true

class SurveyResponsesController < ApplicationController
  def create
    @response = authorize(SurveyResponse.new(survey_response_params))

    if @response.save
      redirect_to '/',
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
