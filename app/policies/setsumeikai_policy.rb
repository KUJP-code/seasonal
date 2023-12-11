# frozen_string_literal: true

class SetsumeikaiPolicy < ApplicationPolicy
  def index?
    user.staff?
  end

  def show?
    user.admin? || area_setsumeikai? || school_setsumeikai?
  end

  def create?
    user.admin? || area_setsumeikai? || school_setsumeikai?
  end

  def edit?
    user.admin? || area_setsumeikai? || school_setsumeikai?
  end

  def update?
    user.admin? || area_setsumeikai? || school_setsumeikai?
  end

  def destroy?
    user.admin? || area_setsumeikai? || school_setsumeikai?
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

  private

  def area_setsumeikai?
    return false unless user.area_manager?

    area_school_ids = user.area_schools.ids
    record.involved_schools.ids.any? { |id| area_school_ids.include?(id) }
  end

  def school_setsumeikai?
    return false unless user.school_manager?

    managed_school_ids = user.managed_schools.ids
    record.involved_schools.ids.any? { |id| managed_school_ids.include?(id) }
  end
end
