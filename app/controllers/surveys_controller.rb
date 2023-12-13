# frozen_string_literal: true

class SurveysController < ApplicationController
  before_action :set_survey, only: %i[edit show update]
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: %i[index]

  def index
    authorize Survey
    @surveys = policy_scope(Survey)
  end

  def show
    @schools = policy_scope(School).includes(:survey_responses)
    @school = authorize(params[:school] ? School.find(params[:school]) : @schools.first)
    @responses = policy_scope(SurveyResponse)
                 .where(survey_id: @survey.id, child_id: @school.children.ids)
                 .includes(child: %i[parent])
  end

  def new
    @survey = authorize Survey.new
  end

  def edit; end

  def create
    @survey = authorize Survey.new(survey_params)

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

  def survey_params
    params.require(:survey).permit(
      :id, :name, :active, questions: %i[text input_type options],
                           criteria: %i[
                             id name katakana_name en_name category
                             grade birthday kindy allergies ssid ele_school_name
                             photos received_hat created_at updated_at parent
                             school_id first_seasonal
                           ]
    )
  end

  def set_survey
    @survey = authorize Survey.find(params[:id])
  end
end
