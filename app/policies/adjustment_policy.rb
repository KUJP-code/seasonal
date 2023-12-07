# frozen_string_literal: true

class AdjustmentPolicy < ApplicationPolicy
  def edit?
    user.staff?
  end
end
