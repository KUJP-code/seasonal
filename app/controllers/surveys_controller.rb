# frozen_string_literal: true

class SurveysController < ApplicationController
  before_action :set_survey, only: %i[show edit update]

  def index
    @surveys = policy_scope(Survey)
  end

  def show; end

  def new
    @survey = Survey.new
  end

  def edit; end

  def create
    @survey = Survey.new(survey_params)

    if @survey.save
      redirect_to surveys_path,
                  notice: "#{@survey.name} survey created  successfully"
    else
      render :new, status: :unprocessable_entity,
                   alert: "Couldn't save survey"
    end
  end

  def update
    if @survey.update(survey_params)
      redirect_to surveys_path,
                  notice: "#{@survey.name} survey updated  successfully"
    else
      render :edit, status: :unprocessable_entity,
                    alert: "Couldn't save survey"
    end
  end

  private

  def set_survey
    @survey = Survey.find(params[:id])
  end

  def survey_params
    params.require(:survey).permit(
      :id, :name, :active, questions: %i[text input_type options],
                           criteria: %i[
                             id name katakana_name en_name category
                             grade birthday kindy allergies ssid ele_school_name
                             photos received_hat created_at updated_at parent
                             school first_seasonal
                           ]
    )
  end
end
