# frozen_string_literal: true

class SchoolPolicy < ApplicationPolicy
  def show?
    user.admin? || user.statistician? || area_school? || sm_managed_school?
  end

  def new?
    user.admin?
  end

  def edit?
    user.admin? || area_school? || sm_managed_school?
  end

  def create?
    user.admin?
  end

  def update?
    user.admin? || area_school? || sm_managed_school?
  end

  def permitted_attributes
    always_permit = %i[
      name address phone nearby_stations bus_areas hiragana image_id email
      nearby_schools prefecture
    ]
    return always_permit if user.school_manager? || user.area_manager?
    return nil unless user.admin?

    always_permit + [
      :area_id,
      { managements_attributes:
       %i[id manageable_id manageable_type manager_id _destroy] }
    ]
  end

  class Scope < Scope
    def resolve
      case user.role
      when 'admin', 'statistician'
        scope.all
      when 'area_manager'
        scope.where(id: user.area_schools.ids)
      when 'school_manager'
        scope.where(id: user.managed_schools.ids)
      else
        scope.none
      end
    end
  end

  private

  def area_school?
    user.area_manager? && user.managed_areas.ids.include?(record.area_id)
  end

  def sm_managed_school?
    user.school_manager? && user.managed_schools.ids.include?(record.id)
  end
end
