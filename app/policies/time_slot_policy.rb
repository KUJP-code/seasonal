# frozen_string_literal: true

class TimeSlotPolicy < ApplicationPolicy
  def index?
    user.staff?
  end

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

  def attendance?
    user.admin? || area_slot? || school_slot?
  end

  def update?
    user.admin? || user.area_manager?
  end

  class Scope < Scope
    def resolve; end
  end

  private

  def area_slot?
    user.area_manager? && user.area_slots.ids.include?(record.id)
  end

  def school_slot?
    user.school_manager? && user.school_slots.ids.include?(record.id)
  end
end
