# frozen_string_literal: true

class ChildPolicy < ApplicationPolicy
  def index?
    user.staff?
  end

  def show?
    staff_or_parent?
  end

  def new?
    return false if user.statistician?

    user.present?
  end

  def edit?
    staff_or_parent?
  end

  def create?
    staff_or_parent?
  end

  def update?
    staff_or_parent?
  end

  def destroy?
    user.staff?
  end

  class Scope < Scope
    def resolve
      case user.role
      when 'admin'
        scope
      when 'area_manager'
        scope.where(id: user.area_children.ids)
      when 'school_manager'
        scope.where(id: user.school_children.ids)
      else
        scope.none
      end
    end
  end

  private

  def staff_or_parent?
    return false if user.statistician?

    user.staff? || user.id == record.parent_id
  end
end
