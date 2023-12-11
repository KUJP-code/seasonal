# frozen_string_literal: true

class SchoolPolicy < ApplicationPolicy
  def show?
    user.admin? || area_school? || sm_managed_school?
  end

  def new?
    user.admin?
  end

  def edit?
    user.admin? || area_school? || sm_managed_school?
  end

  def create?
    user.admin?
  end

  def update?
    user.admin? || area_school? || sm_managed_school?
  end

  class Scope < Scope
    def resolve
      case user.role
      when 'admin', 'statistician'
        School.real
      when 'area_manager'
        user.area_schools
      when 'school_manager'
        user.managed_schools
      end
    end
  end

  private

  def area_school?
    user.area_manager? && user.managed_areas.ids.include?(record.area_id)
  end

  def sm_managed_school?
    user.school_manager? && user.managed_schools.ids.include?(record.id)
  end
end
