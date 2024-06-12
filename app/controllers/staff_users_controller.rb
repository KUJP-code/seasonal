# frozen_string_literal: true

class StaffUsersController < ApplicationController
  before_action :set_user, only: %i[destroy edit update]
  before_action :set_schools_areas, only: %i[edit new]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @staff = policy_scope(
      User.staff.or(User.statistician)
          .order(id: :asc)
          .includes(:managed_areas, :managed_schools),
      policy_scope_class: StaffUserPolicy::Scope
    )
  end

  def new
    @user = authorize(User.new(role: :school_manager),
                      policy_class: StaffUserPolicy)
  end

  def edit; end

  def create
    @user = authorize(User.new(staff_user_params),
                      policy_class: StaffUserPolicy)
    if @user.save
      redirect_to user_path(@user),
                  notice: 'User created successfully.'
    else
      @schools = policy_scope(School)
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(staff_user_params)
      redirect_to user_path(@user),
                  notice: 'User updated successfully.'
    else
      @schools = policy_scope(School)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      redirect_to staff_users_path,
                  notice: 'User deleted successfully.'
    else
      redirect_to staff_users_path,
                  alert: @user.errors.full_messages.to_sentence
    end
  end

  private

  def staff_user_params
    params.require(:user).permit(
      :address, :allowed_ips, :email, :katakana_name, :name, :password,
      :password_confirmation, :phone, :pin, :postcode, :prefecture, :role,
      managements_attributes:
        %i[id manageable_id manageable_type manager_id _destroy]
    )
  end

  def set_schools_areas
    @areas = policy_scope(Area).select(:id, :name)
    @schools = policy_scope(School).select(:id, :name)
  end

  def set_user
    @user = authorize(User.find(params[:id]),
                      policy_class: StaffUserPolicy)
  end
end
