# frozen_string_literal: true

# Handles authorization for Schools
class SchoolPolicy < ApplicationPolicy
  def show?
    user.admin? ||
      user.area_manager? ||
      (user.school_manager? && user.managed_schools.ids.include?(record.id))
  end

  def edit
    user.admin?
  end

  # Decides which schools each role can see stats for
  class Scope < Scope
    def resolve
      case user.role
      when 'admin'
        School.real.order(:id)
      when 'area_manager'
        user.area_schools.order(:id)
      when 'school_manager'
        user.managed_schools.order(:id)
      end
    end
  end
end
