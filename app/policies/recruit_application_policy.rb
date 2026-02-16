# frozen_string_literal: true

class RecruitApplicationPolicy < ApplicationPolicy
  def index?
    user.admin? || user.statistician?
  end

  def show?
    index?
  end

  def destroy?
    user.admin?
  end

  class Scope < Scope
    def resolve
      return scope.all if user.admin? || user.statistician?

      scope.none
    end
  end
end
