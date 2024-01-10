# frozen_string_literal: true

class ChartPolicy < ApplicationPolicy
  def index?
    user.admin? || user.area_manager? || user.statistician?
  end

  def show?
    user.staff? || user.statistician?
  end
end
