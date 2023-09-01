# frozen_string_literal: true

# Handles authorisation for Children
class UploadPolicy < ApplicationPolicy
  def new?
    user.admin?
  end

  def create?
    user.admin?
  end
end
