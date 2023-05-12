# frozen_string_literal: true

# Handles authorisation for CSV upload/export
class CsvPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def download?
    user.admin?
  end

  def update?
    user.admin?
  end

  def upload?
    user.admin?
  end
end
