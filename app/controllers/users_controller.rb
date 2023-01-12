# frozen_string_literal: true

# Controls flow of info for Users resource
class UsersController < ApplicationController
  def index
    redirect_to '/errors/permission' if current_user.customer?
    @users = User.admin_index if current_user.admin?
    @users = User.sm_index(current_user) if current_user.school_manager?
    @users = User.am_index(current_user) if current_user.area_manager?
  end

  def profile
    redirect_to user_path(current_user)
  end

  def show
    @user = User.user_show(params[:id])
    redirect_to '/errors/permission' if current_user.customer? && current_user != @user
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      flash[:notice] = t('.success')
      redirect_to user_path(@user)
    else
      flash.now[:alert] = t('.failure')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])

    if @user.destroy
      flash[:notice] = t('.success')
      redirect_to users_path
    else
      flash.now[:alert] = t('.failure')
    end
  end

  private

  def user_params
    params.require(:user).permit(:id, :email, :password, :password_confirmation,
                                 :ja_first_name, :ja_family_name,
                                 :katakana_name, :en_name, :role, :address,
                                 :phone, :school_id, child_attributes:
                                 %i[id ja_first_name ja_family_name
                                    katakana_name en_name category birthday
                                    level allergies ssid ele_school_name
                                    post_photos needs_hat received_hat
                                    parent_id school_id])
  end
end
