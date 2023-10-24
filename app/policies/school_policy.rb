# frozen_string_literal: true

# Handles authorization for Schools
class SchoolPolicy < ApplicationPolicy
  def show?
    user.admin?
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
        School.all.order(:id)
      when 'area_manager'
        user.area_schools.order(:id)
      when 'school_manager'
        user.managed_schools.order(:id)
      end
    end
  end
end
