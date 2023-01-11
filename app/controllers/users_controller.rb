# frozen_string_literal: true

# Controls flow of info for Users resource
class UsersController < ApplicationController
  def index
    redirect_to '/errors/permission' if current_user.customer?
    @users = User.admin_index if current_user.admin?
    @users = User.sm_index(current_user) if current_user.school_manager?
    @users = User.am_index(current_user) if current_user.area_manager?
  end

  def show
    @user = User.find(params[:id])
    redirect to '/errors/permission' if current_user.customer? && current_user != @user
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
    params.require(:user).permit(:id, :email, :password, :password_confirmation)
  end

  def admin_users
  end

  def sm_users(school_manager)
    
  end

  def am_users(area_manager)
    
  end
end
