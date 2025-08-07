# frozen_string_literal: true

class TimeSlotPolicy < ApplicationPolicy
  def index?
    user.staff?
  end

  def show?
    authorized_staff?
  end

  def new?
    user.admin?
  end

  def create?
    user.admin?
  end

  def edit?
    user.admin?
  end

  def update?
    user.admin? || area_slot?
  end

  def attendance?
    authorized_staff?
  end

  def batch_update_summary?
    user.admin?
  end
  
  class Scope < Scope
    def resolve
      case user.role
      when 'admin'
        scope.all
      when 'area_manager'
        scope.where(id: user.area_slots.ids)
      when 'school_manager'
        scope.where(id: user.school_slots.ids)
      else
        scope.none
      end
    end
  end

  private

  def authorized_staff?
    user.admin? || area_slot? || school_slot?
  end

  def area_slot?
    user.area_manager? && user.area_slots.ids.include?(record.id)
  end

  def school_slot?
    user.school_manager? && user.school_slots.ids.include?(record.id)
  end
end
