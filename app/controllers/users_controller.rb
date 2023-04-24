# frozen_string_literal: true

# Controls flow of info for Users resource
class UsersController < ApplicationController
  def index
    @users = policy_scope(User)
  end

  def profile
    redirect_to user_path(current_user)
  end

  def show
    @user = authorize(User.user_show(params[:id]))
    return redirect_to :no_permission if current_user.customer? && current_user != @user
  end

  def new
    @user = authorize(User.new)
  end

  def edit
    @user = authorize(User.find(params[:id]))
  end

  def create
    @user = authorize(User.new(user_params))

    if @user.save
      flash_success
      redirect_to user_path(@user)
    else
      flash_failure
      render '/auth/sign_up', status: :unprocessable_entity
    end
  end

  def update
    @user = authorize(User.find(params[:id]))

    if @user.update(user_params)
      flash_success
      redirect_to user_path(@user)
    else
      flash_failure
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user = authorize(User.find(params[:id]))
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

    @child.update!(parent_id: params[:parent_id])
    flash_success
    redirect_to child_path(@child)
  end

  def merge_children
    ss_kid = authorize(Child.find(params[:ss_kid]))
    non_ss_kid = authorize(Child.find(params[:non_ss_kid]))

    return redirect_to user_path(non_ss_kid.parent) if non_ss_kid.ssid

    ss_kid.update(parent_id: non_ss_kid.parent_id)
    non_ss_kid.invoices.each do |invoice|
      invoice.update(child_id: ss_kid.id)
    end
    non_ss_kid.update(parent_id: nil)

    flash_success
    redirect_to user_path(ss_kid.parent_id)
  end

  def remove_child
    @child = authorize(Child.find(params[:child_id]))
    @parent = User.find(params[:parent_id])
    @parent.children.delete(@child)

    flash_success
    redirect_to user_path(@parent)
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

  def user_params
    params.require(:user).permit(
      :id, :email, :password, :password_confirmation, :kana_first, :role,
      :prefecture, :address, :postcode, :phone, :first_name,
      :family_name, :email_confirmation, :kana_family,
      children_attributes: %i[id first_name family_name grade
                              katakana_name en_name category birthday
                              level allergies ssid ele_school_name
                              photos needs_hat received_hat first_seasonal
                              parent_id school_id kana_first kana_family]
    )
  end
end
