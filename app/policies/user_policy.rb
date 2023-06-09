# frozen_string_literal: true

# Handles authorisation for Children
class UserPolicy < ApplicationPolicy
  def index?
    user.staff?
  end

  def profile?
    staff_or_user?(user, record)
  end

  def show?
    staff_or_user?(user, record)
  end

  def new?
    user.staff?
  end

  def edit?
    staff_or_user?(user, record)
  end

  def create?
    user.staff?
  end

  def update?
    staff_or_user?(user, record)
  end

  def destroy?
    user.admin? || user.area_manager?
  end

  def merge_children?
    user.staff?
  end

  # Defines scopes for user#index
  class Scope < Scope
    def resolve
      case user.role
      when 'admin'
        scope.all.select(:id, :name, :katakana_name, :email).includes(:children).order(:name)
      when 'area_manager'
        a_users = user.managed_areas.reduce([]) do |array, area|
                  array + area.parents.select(:id, :name, :katakana_name, :email).includes(:children).order(:name)
                end
        a_users + User.all.customer.where.missing(:children)
      else
        s_users = user.managed_schools.reduce([]) do |array, school|
                    array + school.parents.select(:id, :name, :katakana_name, :email).includes(:children).order(:name)
                  end
        s_users + User.all.customer.where.missing(:children)
      end
    end
  end

  private

  def staff_or_user?(user, record)
    user.staff? || user.id == record.id
  end
end
