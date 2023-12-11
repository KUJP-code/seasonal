# frozen_string_literal: true

class EventPolicy < ApplicationPolicy
  def index?
    return false if user.statistician?

    true
  end

  def show?
    return false if user.statistician?

    true
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

  def destroy
    user.admin?
  end

  def attendance?
    user.admin? || area_event? || school_event?
  end

  class Scope < Scope
    def resolve
      case user.role
      when 'admin', 'statistician'
        scope
      when 'area_manager'
        scope.where(id: user.area_events.ids)
      when 'school_manager'
        scope.where(id: user.school_events.ids)
      when 'customer'
        scope.where(id: user.events.ids)
      end
    end
  end

  private

  def area_event?
    user.area_manager? && user.area_events.ids.include?(record.id)
  end

  def school_event?
    user.school_manager? && user.school_events.ids.include?(record.id)
  end
end
