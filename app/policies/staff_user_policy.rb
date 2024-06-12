# frozen_string_literal: true

class StaffUserPolicy < ApplicationPolicy
  def new?
    return false if record.admin? && user != record

    user.admin?
  end

  def show?
    return false if record.admin? && user != record

    user.admin?
  end

  def create?
    return false if record.admin? && user != record

    user.admin?
  end

  def edit?
    return false if record.admin? && user != record

    user.admin?
  end

  def update?
    return false if record.admin? && user != record

    user.admin?
  end

  def destroy?
    return false if record.admin? && user != record

    user.admin?
  end

  class Scope < Scope
    def resolve
      user.admin? ? scope.all : scope.none
    end
  end
end
