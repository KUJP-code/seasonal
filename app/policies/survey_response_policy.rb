# frozen_string_literal: true

class SurveyResponsePolicy < ApplicationPolicy
  def create?
    user.admin? || user.children.ids.include?(record.child_id)
  end

  def update?
    user.admin? || area_child? || school_child?
  end

  class Scope < Scope
    def resolve
      case user.role
      when 'admin', 'statistician'
        scope.all
      when 'area_manager'
        scope.where(id: area_survey_responses.ids)
      when 'school_manager'
        scope.where(id: user.managed_school.survey_responses.ids)
      else
        scope.none
      end
    end
  end

  private

  def area_child?
    user.area_manager? && user.area_children.ids.include?(record.child_id)
  end

  def school_child?
    user.school_manager? && user.managed_school.children.ids.include?(record.child_id)
  end
end
