# frozen_string_literal: true

class SchoolPolicy < ApplicationPolicy
  def show?
    user.admin? || user.statistician? ||
      (user.school_manager? && user.managed_school.id == record.id)
  end

  def new?
    user.admin?
  end

  def edit?
    user.admin?
  end

  def create?
    user.admin?
  end

  def update?
    user.admin?
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
end
