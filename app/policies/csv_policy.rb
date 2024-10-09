# frozen_string_literal: true

class CsvPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def download?
    user.admin?
  end

  def emails?
    user.admin?
  end

  def photo_kids?
    user.admin?
  end

  def no_photo_emails?
    user.admin?
  end

  def update?
    user.admin?
  end

  def upload?
    user.admin?
  end
end
