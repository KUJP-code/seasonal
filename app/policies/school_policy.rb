# frozen_string_literal: true

# Handles authorization for Schools
class SchoolPolicy < ApplicationPolicy
  def show?
    user.admin? ||
    user.area_manager? ||
    (user.school_manager? && user.managed_schools.ids.include?(record.id))
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
