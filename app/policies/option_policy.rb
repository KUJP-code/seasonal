# frozen_string_literal: true

# Handles authorisation of Option actions
class OptionPolicy < ApplicationPolicy
  def create?
    user.staff?
  end

  def destroy?
    user.staff?
  end
end
