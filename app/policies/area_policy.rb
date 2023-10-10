# frozen_string_literal: true

# Handles authorization for Areas
class AreaPolicy < ApplicationPolicy
  # Decides which areas each role can see stats for
  class Scope < Scope
    def resolve
      case user.role
      when 'admin'
        Area.all.order(:id)
      when 'area_manager'
        user.managed_areas
      end
    end
  end
end
