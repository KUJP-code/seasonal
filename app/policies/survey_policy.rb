# frozen_string_literal: true

class SurveyPolicy < ApplicationPolicy
  def index?
    user.staff?
  end

  def show?
    user.staff?
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
      user.staff? ? Survey.all : []
    end
  end
end
