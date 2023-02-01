# frozen_string_literal: true

# Controls flow of info for Users resource
class UsersController < ApplicationController
  def index
    return redirect_to :no_permission if current_user.customer?

    @users = index_for_role
  end

  def profile
    redirect_to user_path(current_user)
  end

  def show
    @user = User.user_show(params[:id])
    return redirect_to :no_permission if current_user.customer? && current_user != @user
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)

    if @user.save
      flash_success
      redirect_to user_path(@user)
    else
      flash_failure
      render '/auth/sign_up', status: :unprocessable_entity
    end
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      flash_success
      redirect_to user_path(@user)
    else
      flash_failure
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])
    return redirect_to :required_user if delete_admin?
    return redirect_to :no_permission if current_user.customer?

    if @user.destroy
      flash_success
      redirect_to users_path
    else
      flash_failure
    end
  end

  def add_child
    @child = Child.find(params[:child_id])
    return redirect_to :child_theft unless @child.parent_id.nil?

    update_child
    respond_to do |format|
      flash_success
      format.turbo_stream
    end
  end

  def remove_child
    @child = Child.find(params[:child_id])
    @parent = User.find(params[:parent_id])
    @parent.children.delete(@child)

    respond_to do |format|
      flash_success
      format.turbo_stream
    end
  end

  private

  def delete_admin?
    @user.admin? && User.admins.size <= 1
  end

  def flash_failure
    flash.now[:alert] = t('.failure')
  end

  def flash_success
    flash.now[:notice] = t('.success')
  end

  def index_for_role
    return User.admin_index if current_user.admin?
    return User.sm_index(current_user) if current_user.school_manager?
    return User.am_index(current_user) if current_user.area_manager?
  end

  def update_child
    @parent = User.find(params[:parent_id])
    @parent.children << @child
    @child.school = @parent.school
    @child.save
  end

  def user_params
    params.require(:user).permit(:id, :email, :password, :password_confirmation,
                                 :ja_first_name, :ja_family_name,
                                 :katakana_name, :role, :prefecture, :address, :postcode, :phone, :school_id,
                                 children_attributes:
                                 %i[id ja_first_name ja_family_name
                                    katakana_name en_name category birthday
                                    level allergies ssid ele_school_name
                                    post_photos needs_hat received_hat
                                    parent_id school_id])
  end
end
