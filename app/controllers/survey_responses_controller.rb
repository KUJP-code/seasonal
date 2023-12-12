# frozen_string_literal: true

class SurveyResponsesController < ApplicationController
  after_action :verify_authorized

  def create
    @response = authorize SurveyResponse.new(survey_response_params)

    if @response.save
      redirect_to '/',
                  notice: t('.response_appreciated')
    else
      redirect_to '/', alert: t('.unable_to_process')
    end
  end

  def update
    @response = authorize SurveyResponse.find(params[:id])

    if @response.update(survey_response_params)
      redirect_to survey_path(@response.survey),
                  notice: 'Comment added'
    else
      redirect_back alert: 'Failed to add comment'
    end
  end

  private

  def survey_response_params
    params
    params.require(:survey_response).permit(
      :id, :child_id, :comment, :survey_id, answers: {}
    )
  end
end
