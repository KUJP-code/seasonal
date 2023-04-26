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
    user.admin?
  end

  # Handles scopes for TimeSlot index
  class Scope < Scope
    def resolve
      case user.role
      when 'admin'
        Event.all.includes(:time_slots)
      when 'area_manager'
        user.area_events.includes(:time_slots)
      when 'school_manager'
        user.school_events.includes(:time_slots)
      else
        user.children_events.includes(:time_slots)
      end
    end
  end
end
