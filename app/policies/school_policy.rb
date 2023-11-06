# frozen_string_literal: true

# Handles authorization for Schools
class SchoolPolicy < ApplicationPolicy
  def show?
    user.admin? ||
      (user.school_manager? && user.managed_schools.ids.include?(record.id))
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

  # Decides which schools each role can see stats for
  class Scope < Scope
    def resolve
      case user.role
      when 'admin'
        School.real.order(:id)
      when 'area_manager'
        user.area_schools.real.order(:id)
      when 'school_manager'
        user.managed_schools.real.order(:id)
      end
    end
  end
end
