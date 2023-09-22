# frozen_string_literal: true

# Handles authorization for Schools
class SchoolPolicy < ApplicationPolicy
  def show?
    user.admin? ||
      user.area_manager? ||
      (user.school_manager? && user.managed_schools.ids.include?(record.id))
  end

  # Decides which schools each role can see stats for
  class Scope < Scope
    def resolve
      case user.role
      when 'admin'
        School.real.order(:id)
      when 'area_manager'
        School.real.where(id: user.area_schools.ids).order(:id)
      end
    end
  end
end
