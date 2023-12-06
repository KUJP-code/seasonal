# frozen_string_literal: true

# Handles authorisation for events
class EventPolicy < ApplicationPolicy
  def show?
    staff_or_parent?(user, record)
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
      when 'admin'
        Event.order(start_date: :desc).includes(:school)
      when 'area_manager'
        user.area_events.includes(:school)
      when 'school_manager'
        user.school_events.includes(:school)
      else
        user.schools.first.events
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

  def staff_or_parent?(user, record)
    user.staff? || user.id == record.parent_id
  end
end
