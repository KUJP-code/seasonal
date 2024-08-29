# frozen_string_literal: true

class StaffUserPolicy < ApplicationPolicy
  def new?
    user.admin?
  end

  def show?
    user.admin?
  end

  def create?
    user.admin?
  end

  def edit?
    user.admin?
  end

  def update?
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
