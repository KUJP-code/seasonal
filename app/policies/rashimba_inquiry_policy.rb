# frozen_string_literal: true

class RashimbaInquiryPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  alias show? index?
  alias update? index?
  alias destroy? index?

  class Scope < Scope
    def resolve
      user.admin? ? scope.all : scope.none
    end
  end
end
