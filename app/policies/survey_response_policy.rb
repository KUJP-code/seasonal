# frozen_string_literal: true

class SurveyPolicy < ApplicationPolicy
  def index?
    user.staff?
  end

  def create?
    user.customer?
  end

  class Scope < Scope
    def resolve
      case user.role
      when 'admin', 'area_manager'
        SurveyResponse.all
      when 'school_manager'
        user.managed_school.survey_responses
      end
    end
  end
end
