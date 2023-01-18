# frozen_string_literal: true

# Handles flow of data for schools
class SchoolsController < ApplicationController
  def index
    return redirect_to :no_permission if current_user.customer?

    @schools = index_for_role
  end

  private

  def index_for_role
    return School.all if current_user.admin?
    return current_user.managed_schools if current_user.area_manager? || current_user.school_manager?
  end
end
