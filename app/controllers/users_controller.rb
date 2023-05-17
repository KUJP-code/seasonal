# frozen_string_literal: true

# Controls flow of info for Users resource
class UsersController < ApplicationController
  def index
    authorize(User)
    @users = if current_user.admin?
               policy_scope(User).page(params[:page]).per(500)
             else
               policy_scope(User)
             end
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
      render :new, status: :unprocessable_entity
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
    authorize(User)
    ss_kid = Child.find(params[:ss_kid])
    non_ss_kid = Child.find(params[:non_ss_kid])

    ss_kid.update(parent_id: non_ss_kid.parent_id)
    copy_invoices(non_ss_kid, ss_kid)
    non_ss_kid.update(parent_id: nil)

    redirect_to child_path(ss_kid), notice: t('.success')
  end

  private

  def already_registered?(t_regs, o_reg)
    t_regs.any? do |t_reg|
      t_reg.registerable_id == o_reg.registerable_id && t_reg.registerable_type == o_reg.registerable_type
    end
  end

  def copy_invoices(from, to)
    if to.invoices.empty?
      move_invoices(from, to)
    else
      merge_invoices(from, to)
    end
  end

  def delete_admin?
    @user.admin? && User.admins.size <= 1
  end

  def flash_failure
    flash.now[:alert] = t('.failure')
  end

  def flash_success
    flash.now[:notice] = t('.success')
  end

  def merge_invoices(from, to)
    from_regs = from.invoices.map(&:registrations).flatten
    to_regs = to.invoices.map(&:registrations).flatten
    to_active_invoice = to.invoices.find_by(in_ss: false) || to.invoices.create(event_id: from.invoices.first.event_id)

    from_regs.each do |reg|
      # Skip if already registered
      next if already_registered?(to_regs, reg)

      # Else associate reg with to child and their open invoice
      reg.update(child_id: to.id, invoice_id: to_active_invoice.id)
    end

    to_active_invoice.save
  end

  def move_invoices(from, to)
    from.invoices.each do |invoice|
      # Change the child associated with the invoice
      invoice.update(child_id: to.id)
      # Same for each registration on the invoice
      invoice.registrations.each do |reg|
        reg.update(child_id: to.id)
      end
      # Update the invoice to reflect its new owner
      invoice.save
    end
  end

  def user_params
    params.require(:user).permit(
      :id, :email, :kana_first, :prefecture, :address, :postcode, :phone,
      :first_name, :family_name, :email_confirmation, :kana_family
    )
  end
end
