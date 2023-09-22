# frozen_string_literal: true

# Handles authorization for Adjustments
class ChartPolicy < ApplicationPolicy
  def index?
    user.admin? || user.area_manager?
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
