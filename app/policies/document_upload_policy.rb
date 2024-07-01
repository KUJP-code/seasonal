# frozen_string_literal: true

class DocumentUploadPolicy < ApplicationPolicy
  def index?
    true if user.admin? || user.area_manager? || user.school_manager?
  end

  class Scope < Scope
    def resolve
      case user.role
      when 'admin'
        scope.all
      when 'area_manager'
        scope.where(school_id: user.area_schools.ids)
      when 'school_manager'
        scope.where(school_id: user.managed_schools.ids)
      else
        scope.none
      end
    end
  end
end
