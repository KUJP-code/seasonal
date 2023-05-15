# frozen_string_literal: true

# Handles authorisation for Children
class ChildPolicy < ApplicationPolicy
  def index?
    user.staff?
  end

  def show?
    staff_or_parent?(user, record)
  end

  def edit?
    staff_or_parent?(user, record)
  end

  def create?
    staff_or_parent?(user, record)
  end

  def update?
    staff_or_parent?(user, record)
  end

  def destroy?
    user.staff?
  end

  # Handles authorisation for children index scopes
  # attendance sheets handled by the controller
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all.order(:name).includes(:parent, :school)
      elsif user.area_manager?
        area_schools = user.managed_areas.reduce([]) { |schools, area| schools + area.schools.ids }
        scope.where(school_id: area_schools).order(:name).includes(:parent, :school)
      else
        scope.where(school_id: user.managed_schools.ids).order(:name).includes(:parent, :school)
      end
    end
  end

  def staff_or_parent?(user, record)
    user.staff? || user.id == record.parent_id
  end
end
