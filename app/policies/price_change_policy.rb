# frozen_string_literal: true

class PriceChangePolicy < ApplicationPolicy
  def index?
    user.staff?
  end

  def update?
    user.staff? && Scope.new(user, PriceChange).resolve.exists?(record.id)
  end

  class Scope < Scope
    def resolve
      case user.role
      when 'admin'
        scope.all
      when 'area_manager'
        scope.for_schools(user.area_schools.ids)
      when 'school_manager'
        scope.for_schools(user.managed_schools.ids)
      else
        scope.none
      end
    end
  end
end
