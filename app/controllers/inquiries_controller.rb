# frozen_string_literal: true

class InquiriesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def index
    return admin_index if current_user.admin?

    @inquiries = policy_scope(Inquiry).order(created_at: :desc)
                                      .includes(:setsumeikai)
                                      .page(params[:page])
  end

  def new
    @inquiry = Inquiry.new
    @setsumeikais = policy_scope(Setsumeikai).upcoming
                                             .order(start: :asc)
                                             .includes(:school)
    @schools = School.real.order(:id)
  end

  def edit
    @inquiry = authorize(Inquiry.find(params[:id]))
    @setsumeikais = policy_scope(Setsumeikai).upcoming
                                             .order(start: :asc)
                                             .includes(:school)
    @schools = School.real.order(:id)
  end

  def create
    @inquiry = Inquiry.new(inquiry_params)

    respond_to do |format|
      format.json { create_json_response }
      format.html { create_html_response }
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
      :start_date, :notes, :requests
    )
  end

  def admin_index
    @schools = policy_scope(School).order(:id)
    @school = params[:school] ? School.find(params[:school]) : @schools.first
    @inquiries = @school.inquiries.includes(:setsumeikai)
  end

  def create_html_response
    if @inquiry.save
      redirect_to setsumeikai_path(@inquiry.setsumeikai_id),
                  notice: 'Created inquiry'
    else
      @schools = policy_scope(School)
      render :new,
             status: :unprocessable_entity,
             alert: 'Failed to create inquiry'
    end
  end

  def create_json_response
    if @inquiry.save
      render json: { status: 200 }
    else
      render json: { status: 500 }
    end
  end
end
