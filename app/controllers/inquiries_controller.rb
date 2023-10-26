# frozen_string_literal: true

class InquiriesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def index
    return admin_index if current_user.admin?

    @inquiries = policy_scope(Inquiry).includes(:setsumeikai)
  end

  def new
    @inquiry = Inquiry.new
    @setsumeikais = policy_scope(Setsumeikai).upcoming.order(start: :asc)
    @schools = policy_scope(School)
  end

  def edit
    @inquiry = authorize(Inquiry.find(params[:id]))
    @setsumeikais = policy_scope(Setsumeikai).upcoming.order(start: :asc)
    @schools = policy_scope(School)
  end

  def create
    # TODO: add a response for the API endpoint
    @inquiry = Inquiry.new(inquiry_params)

    if @inquiry.save
      redirect_to inquiries_path,
                  notice: 'Created inquiry'
    else
      @schools = policy_scope(School)
      render :new,
             status: :unprocessable_entity,
             alert: 'Failed to create inquiry'
    end
  end

  def update
    @inquiry = authorize(Inquiry.find(params[:id]))

    if @inquiry.update(inquiry_params)
      redirect_to inquiries_path,
                  notice: 'Updated inquiry'
    else
      render :edit,
             status: :unprocessable_entity,
             alert: 'Failed to update inquiry'
    end
  end

  def destroy
    @inquiry = authorize(Inquiry.find(params[:id]))

    if @inquiry.destroy
      redirect_to inquiries_path, notice: 'Deleted Inquiry'
    else
      redirect_to inquiries_path, alert: 'Failed to delete Inquiry'
    end
  end

  private

  def inquiry_params
    params.require(:inquiry).permit(
      :id, :setsumeikai_id, :parent_name, :phone, :email, :child_name,
      :referrer, :child_birthday, :kindy, :ele_school, :planned_school,
      :start_date
    )
  end

  def admin_index
    @schools = policy_scope(School).order(:id)
    @school = params[:school] ? School.find(params[:school]) : @schools.first
    @inquiries = @school.inquiries.includes(:setsumeikai)
  end
end
