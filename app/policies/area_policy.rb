# frozen_string_literal: true

# Handles authorization for Areas
class AreaPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  # Decides which areas each role can see stats for
  class Scope < Scope
    def resolve
      case user.role
      when 'admin'
        Area.order(:id)
      when 'area_manager'
        user.managed_areas
      end
    end
  end
end
