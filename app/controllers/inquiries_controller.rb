# frozen_string_literal: true

class InquiriesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  after_action :verify_authorized, except: :create
  after_action :verify_policy_scoped, only: :index

  def index
    @schools = policy_scope(School).real.order(:id)
    @school = params[:school] ? School.find(params[:school]) : @schools.first
    @inquiries = @school.inquiries.includes(:setsumeikai).page(params[:page])
  end

  def new
    @inquiry = Inquiry.new(setsumeikai_id: params[:setsu_id])
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

  private

  def inquiry_params
    params.require(:inquiry).permit(
      :id, :setsumeikai_id, :parent_name, :phone, :email, :child_name,
      :referrer, :child_birthday, :kindy, :ele_school, :start_date, :notes,
      :requests, :category, :school_id
    )
  end

  def create_html_response
    if @inquiry.save
      if @inquiry.category == 'R'
        redirect_to setsumeikai_path(@inquiry.setsumeikai_id),
                    notice: 'Created inquiry'
      else
        redirect_to inquiries_path(school: @inquiry.school_id),
                    notice: 'Created inquiry'
      end
    else
      @schools = policy_scope(School)
      render :new,
             status: :unprocessable_entity,
             alert: 'Failed to create inquiry'
    end
  end

  def create_json_response
    if @inquiry.save
      send_mail(@inquiry)
      render json: { status: 200 }
    else
      render json: { status: 500 }
    end
  end

  def send_mail(inquiry)
    if inquiry.category == 'R'
      InquiryMailer.with(inquiry: @inquiry).setsu_inquiry.deliver_now
    else
      InquiryMailer.with(inquiry: @inquiry).inquiry.deliver_now
    end
  end
end
