# frozen_string_literal: true

class SetsumeikaiPolicy < ApplicationPolicy
  def index?
    user.staff?
  end

  def show?
    user.admin? || area_setsumeikai? || school_setsumeikai?
  end

  def create?
    user.admin? || managing_area_setsumeikai? || managing_school_setsumeikai?
  end

  def edit?
    user.admin? || managing_area_setsumeikai? || managing_school_setsumeikai?
  end

  def update?
    user.admin? || managing_area_setsumeikai? || managing_school_setsumeikai?
  end

  def destroy?
    user.admin? || managing_area_setsumeikai? || managing_school_setsumeikai?
  end

  class Scope < Scope
    def resolve
      case user.role
      when 'admin'
        scope.all
      when 'area_manager'
        scope.where(id: user.area_setsumeikais.ids)
      when 'school_manager'
        scope.where(id: user.school_setsumeikais.ids)
      else
        scope.none
      end
    end
  end

  private

  def area_setsumeikai?
    return false unless user.area_manager?

    area_school_ids = user.area_schools.ids

    record.involved_schools.ids.any? { |id| area_school_ids.include?(id) }
  end

  def managing_area_setsumeikai?
    return false unless user.area_manager?

    user.area_schools.ids.include?(record.school_id)
  end

  def managing_school_setsumeikai?
    return false unless user.school_manager?

    user.managed_schools.ids.include?(record.school_id)
  end

  def school_setsumeikai?
    return false unless user.school_manager?

    managed_school_ids = user.managed_schools.ids
    record.involved_schools.ids.any? { |id| managed_school_ids.include?(id) }
  end
end
