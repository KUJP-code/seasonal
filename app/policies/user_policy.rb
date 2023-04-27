# frozen_string_literal: true

# Handles authorisation for Children
class UserPolicy < ApplicationPolicy
  def index?
    user.staff?
  end

  def profile?
    staff_or_user?(user, record)
  end

  def show?
    staff_or_user?(user, record)
  end

  def new?
    user.staff?
  end

  def edit?
    staff_or_user?(user, record)
  end

  def create?
    user.staff?
  end

  def update?
    staff_or_user?(user, record)
  end

  def destroy?
    user.admin? || user.area_manager?
  end

  def merge_children?
    user.staff?
  end

  # Defines scopes for user#index
  class Scope < Scope
    def resolve
      case user.role
      when 'admin'
        scope.all
      when 'area_manager'
        user.managed_areas.reduce([]) { |array, a| array + a.parents }
      else
        user.managed_schools.reduce([]) { |array, s| array + s.parents }
      end
    end
  end

  private

  def staff_or_user?(user, record)
    user.staff? || user.id == record.id
  end
end
