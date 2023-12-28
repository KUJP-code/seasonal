# frozen_string_literal: true

class AreaPolicy < ApplicationPolicy
  def index?
    user.admin? || user.area_manager?
  end

  def show?
    user.admin? || (user.area_manager? && user.managed_areas.include?(record))
  end

  def new?
    user.admin?
  end

  def edit?
    user.admin?
  end

  def create?
    user.admin?
  end

  def update?
    user.admin?
  end

  class Scope < Scope
    def resolve
      case user.role
      when 'admin'
        scope.all
      when 'area_manager'
        scope.where(id: user.managed_areas.ids)
      else
        scope.none
      end
    end
  end
end
