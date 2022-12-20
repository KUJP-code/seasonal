# frozen_string_literal: true

# Controls flow of info for Users resource
class UsersController < ApplicationController
  def index
    @users = User.all.order(updated_at: :desc).limit(20) if current_user.admin?
    # Limit AM to Users in their area
    # @users = current_user.area.users.order(updated_at: :desc).limit(10) if current_user.area_manager?
    # Limit SM to Users at their school
    # @users = current_user.school.users.order(updated_at: :desc).limit(10) if current_user.admin?
  end
end
