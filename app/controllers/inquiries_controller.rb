# frozen_string_literal: true

class InquiriesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  after_action :verify_authorized, except: %i[index create]
  after_action :verify_policy_scoped, only: :index

  def index
    authorize Inquiry
    @schools = policy_scope(School).real.order(:id)
    school_given = params[:school] && params[:school] != '0'
    @school = school_given ? School.find(params[:school]) : default_school
    @inquiries = index_inquiries
  end

  def new
    @inquiry = authorize Inquiry.new(setsumeikai_id: params[:setsu_id])
    @setsumeikais = policy_scope(Setsumeikai).upcoming
                                             .order(start: :asc)
                                             .includes(:school)
    @schools = policy_scope(School).order(:id)
  end

  def edit
    @inquiry = authorize Inquiry.find(params[:id])
    @setsumeikais = policy_scope(Setsumeikai).upcoming
                                             .order(start: :asc)
                                             .includes(:school)
    @schools = policy_scope(School).order(:id)
  end

  def create
    @inquiry = Inquiry.new(inquiry_params)

    respond_to do |format|
      format.json { create_json_response }
      format.html { create_html_response }
    end
  end

  def update
    @inquiry = authorize Inquiry.find(params[:id])

    if @inquiry.update(inquiry_params)
      redirect_to inquiries_path,
                  notice: t('success', model: '問い合わせ', action: '更新')
    else
      render :edit,
             status: :unprocessable_entity,
             alert: t('failure', model: '問い合わせ', action: '更新')
    end
  end

  def destroy
    @inquiry = authorize Inquiry.find(params[:id])
    @inquiry.destroy
    redirect_to inquiries_path,
                notice: t('success', model: '問い合わせ', action: '削除')
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
                    notice: t('success', model: '問い合わせ', action: '作成')
      else
        redirect_to inquiries_path(school: @inquiry.school_id),
                    notice: t('success', model: '問い合わせ', action: '作成')
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

  def default_school
    if current_user.school_manager?
      current_user.managed_school
    else
      School.new(id: 0)
    end
  end

  def index_inquiries
    scoped_inquiries = policy_scope(@school.id.zero? ? Inquiry : @school.inquiries)
                       .includes(:setsumeikai)
                       .order(created_at: :desc)
                       .page(params[:page])
    return scoped_inquiries unless params[:category]

    params[:category] == 'R' ? scoped_inquiries.setsumeikai : scoped_inquiries.general
  end

  def send_mail(inquiry)
    if inquiry.category == 'R'
      InquiryMailer.with(inquiry: @inquiry).setsu_inquiry.deliver_now
    else
      InquiryMailer.with(inquiry: @inquiry).inquiry.deliver_now
    end
  end
end
