# frozen_string_literal: true

class SurveyResponsePolicy < ApplicationPolicy
  def create?
    user.customer? || user.admin?
  end

  class Scope < Scope
    def resolve
      case user.role
      when 'admin', 'statistician'
        SurveyResponse.all
      when 'area_manager'
        user.area_survey_responses
      when 'school_manager'
        user.managed_school.survey_responses
      end
    end
  end
end
