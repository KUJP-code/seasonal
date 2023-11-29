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
        Inquiry.all
      when 'area_manager', 'school_manager'
        user.all_inquiries
      end
    end
  end
end
