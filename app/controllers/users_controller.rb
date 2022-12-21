# frozen_string_literal: true

# Controls flow of info for Users resource
class UsersController < ApplicationController
  def index
    case current_user.role
    when 'admin'
      @users = User.all.order(updated_at: :desc).limit(20)
    when 'school_manager'
      # TODO: Limit SM to Users at their school
      # @users = current_user.school.users.order(updated_at: :desc).limit(10) if current_user.admin?
      @users = User.all.order(updated_at: :desc).limit(21)
    when 'area_manager'
      # TODO: Limit AM to Users in their area
      # @users = current_user.area.users.order(updated_at: :desc).limit(10) if current_user.area_manager?
      @users = User.all.order(updated_at: :desc).limit(22)
    else
      # TODO: once db is filled out this will go to an error page
      @users = User.all.order(updated_at: :desc).limit(25)
    end
  end

  def show
    @user = User.find(params[:id])
    redirect to 'errors/permission' if current_user.customer? && current_user != @user
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
end
