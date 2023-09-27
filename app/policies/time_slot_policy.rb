# frozen_string_literal: true

# Handles authorisation for TimeSlots
class TimeSlotPolicy < ApplicationPolicy
  def show?
    user.admin?
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
    user.admin? || user.area_manager?
  end

  # Handles scopes for TimeSlot index
  class Scope < Scope
    def resolve
      case user.role
      when 'admin'
        Event.upcoming.real
      when 'area_manager'
        user.area_events.upcoming.real
      when 'school_manager'
        user.school_events
      else
        user.events.upcoming.real
      end
    end
  end
end
