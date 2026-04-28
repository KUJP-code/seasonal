# frozen_string_literal: true

class RecruitApplicationPolicy < ApplicationPolicy
  def index?
    user.admin? || user.statistician? || user.recruiter_access?
  end

  def show?
    index?
  end

  def update?
    user.admin? || user.recruiter_access?
  end

  def destroy?
    user.admin?
  end

  class Scope < Scope
    def resolve
      return scope.all if user.admin? || user.statistician? || user.recruiter_access?

      scope.none
    end
  end
end
