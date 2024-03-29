# frozen_string_literal: true

class InquiryPolicy < ApplicationPolicy
  def index?
    user.staff?
  end

  def show?
    authorized_staff?
  end

  def new?
    user.staff?
  end

  def edit?
    authorized_staff?
  end

  def create?
    authorized_staff?
  end

  def update?
    authorized_staff?
  end

  def destroy?
    authorized_staff?
  end

  class Scope < Scope
    def resolve
      case user.role
      when 'admin', 'statistician'
        scope.all
      when 'area_manager', 'school_manager'
        scope.where(id: user.all_inquiries.ids)
      else
        scope.none
      end
    end
  end

  private

  def authorized_staff?
    user.admin? || area_inquiry? || school_inquiry?
  end

  def area_inquiry?
    user.area_manager? && user.managed_areas.ids.include?(record.area.id)
  end

  def school_inquiry?
    user.school_manager? && user.managed_schools.ids.include?(record.school_id)
  end
end
