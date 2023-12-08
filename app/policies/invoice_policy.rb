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

  private

  def staff_or_parent?(user, record)
    user.staff? || user.children.ids.include?(record.child_id)
  end
end
