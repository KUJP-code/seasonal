# frozen_string_literal: true

class RecruitTrackingLinkPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def create?
    user.admin?
  end

  def update?
    user.admin?
  end

  def remove?
    update?
  end

  class Scope < Scope
    def resolve
      return scope.all if user.admin?

      scope.none
    end
  end
end
