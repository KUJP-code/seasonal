# frozen_string_literal: true

class InvoicePolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    staff_or_parent?(user, record)
  end

  def new?
    user.present?
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

  def confirm?
    staff_or_parent?(user, record)
  end

  def confirmed?
    true
  end

  def copy?
    staff_or_parent?(user, record)
  end

  def merge?
    user.staff?
  end

  def seen?
    user.staff?
  end

  class Scope < Scope
    def resolve
      case user.role
      when 'admin'
        scope
      when 'area_manager'
        scope.where(event_id: user.area_events.ids)
      when 'school_manager'
        scope.where(event_id: user.school_events.ids)
      when 'customer'
        scope.where(id: user.invoices.ids)
      else
        scope.none
      end
    end
  end

  private

  def staff_or_parent?(user, record)
    user.staff? || user.children.ids.include?(record.child_id)
  end
end
