# frozen_string_literal: true

# Handles authorisation for Invoices
class InvoicePolicy < ApplicationPolicy
  def index?
    user.staff? || record.all? { |invoice| user.children.ids.include?(invoice.child_id) }
  end

  def show?
    staff_or_parent?(user, record)
  end

  def update?
    staff_or_parent?(user, record)
  end

  def confirm?
    staff_or_parent?(user, record)
  end

  def copy?
    staff_or_parent?(user, record)
  end

  def merge?
    user.staff?
  end

  def resurrect?
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
