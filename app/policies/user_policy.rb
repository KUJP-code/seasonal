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

  def destroy?
    user.admin?
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
        scope.where.missing(:children)
             .where(role: :customer)
             .or(scope.where(id: user.area_parents.ids)).distinct
      when 'school_manager'
        scope.where.missing(:children)
             .where(role: :customer)
             .or(scope.where(id: user.school_parents.ids)).distinct
      else
        scope.none
      end
    end
  end

  private

  def staff_or_user?
    if record.staff?
      user.admin? ||
        user.id == record.id ||
        (user.area_manager? &&
         user.area_school_managers.ids.include?(record.id))
    else
      user.staff? || user.id == record.id
    end
  end
end
