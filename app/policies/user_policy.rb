# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    user.staff?
  end

  def show?
    staff_or_user?
  end

  def new?
    user.staff?
  end

  def create?
    user.staff?
  end

  def edit?
    staff_or_user?
  end

  def update?
    staff_or_user?
  end

  def merge_children?
    user.staff?
  end

  class Scope < Scope
    def resolve
      case user.role
      when 'admin'
        scope.all
      when 'area_manager'
        scope.where(id: user.area_parents.ids)
      when 'school_manager'
        scope.where(id: user.school_parents.ids)
      else
        scope.none
      end
    end
  end

  private

  def staff_or_user?
    if record.staff?
      user.admin? || user.id == record.id
    else
      user.staff? || user.id == record.id
    end
  end
end
