class OptionPolicy < ApplicationPolicy
  def create?
    user.staff?
  end

  def destroy?
    user.staff?
  end
end
