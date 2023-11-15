# frozen_string_literal: true

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

  def destroy?
    admin_am_or_managed_school?
  end

  class Scope < Scope
    def resolve
      case user.role
      when 'admin'
        Setsumeikai.includes(:school)
      when 'area_manager'
        user.area_setsumeikais
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
