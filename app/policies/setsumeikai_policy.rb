# frozen_string_literal: true

# Handles authorization for Setsumeikais
class SetsumeikaiPolicy < ApplicationPolicy
  def index?
    user.staff?
  end

  def show?
    admin_am_or_managed_school?
  end

  def create?
    admin_am_or_managed_school?
  end

  def edit?
    admin_am_or_managed_school?
  end

  def update?
    admin_am_or_managed_school?
  end

  # Decides which schools each role can see stats for
  class Scope < Scope
    def resolve
      case user.role
      when 'admin'
        Setsumeikai.all.includes(:school)
      when 'area_manager'
        user.all_setsumeikais
      when 'school_manager'
        user.school_setsumeikais
      end
    end
  end

  def admin_am_or_managed_school?
    user.admin? ||
      user.area_manager? ||
      (user.school_manager? && user.managed_school.id == record.school_id)
  end
end
