# frozen_string_literal: true

class SurveyPolicy < ApplicationPolicy
  def index?
    user.staff? || user.statistician?
  end

  def show?
    user.staff? || user.statistician?
  end

  def new?
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

  class Scope < Scope
    def resolve
      user.staff? || user.statistician? ? Survey.all : []
    end
  end
end
