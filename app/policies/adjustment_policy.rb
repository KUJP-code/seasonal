# frozen_string_literal: true

# Handles authorization for Adjustments
class AdjustmentPolicy < ApplicationPolicy
  def edit?
    user.staff?
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
