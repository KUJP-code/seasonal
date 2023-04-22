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

  # Handles authorisation for event index scopes
  # attendance sheets handled by the controller
  class Scope < Scope
    def resolve
      case user.role
      when 'admin'
        Event.all.with_attached_image
      when 'area_manager'
        user.area_events.with_attached_image
      when 'school_manager'
        user.school_events.with_attached_image
      else
        user.children_events
      end
    end
  end

  private

  def staff_or_parent?(user, record)
    user.staff? || user.id == record.parent_id
  end
end
