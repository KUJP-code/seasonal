# frozen_string_literal: true

# Handles authorisation for TimeSlots
class TimeSlotPolicy < ApplicationPolicy
  def index?
    user.staff?
  end

  def show?
    user.admin?
  end

  def edit?
    user.admin?
  end

  def update?
    user.admin? || user.area_manager?
  end

  # Handles scopes for TimeSlot index
  class Scope < Scope
    def resolve
      case user.role
      when 'admin'
        Event.all.includes(:school)
      when 'area_manager'
        user.area_events.includes(:school)
      when 'school_manager'
        user.school_events.includes(:school)
      else
        user.children_events.includes(:school)
      end
    end
  end
end
