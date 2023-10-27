# frozen_string_literal: true

# Handles authorization for Schools
class InquiryPolicy < ApplicationPolicy
  def index?
    user.staff?
  end

  def new?
    user.staff?
  end

  def edit?
    user.staff?
  end

  def create?
    user.staff?
  end

  def update?
    user.staff?
  end

  def destroy?
    user.staff?
  end

  # Decides which schools each role can see stats for
  class Scope < Scope
    def resolve
      case user.role
      when 'admin'
        Inquiry.all.order(:id)
      when 'area_manager'
        user.area_inquiries.order(:id)
      when 'school_manager'
        user.school_inquiries.order(:id)
      end
    end
  end
end
