# frozen_string_literal: true

class InquiriesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  after_action :verify_authorized, except: %i[index create]
  after_action :verify_policy_scoped, only: :index

  def index
    authorize Inquiry
    @schools = policy_scope(School).order(:id)
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
    params[:inquiry] ||= JSON.parse(request.body.read)["inquiry"] if request.format.json?
    @inquiry = Inquiry.new(inquiry_params.except(:recaptcha_token))

    if recaptcha_needed_and_invalid?(inquiry_params[:recaptcha_token])
      handle_failed_recaptcha and return
    end

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
    raw = params[:inquiry] || params
    ActionController::Parameters.new(raw).permit(
      :id, :setsumeikai_id, :parent_name, :phone, :email, :child_name,
      :referrer, :child_birthday, :kindy, :ele_school, :start_date, :notes,
      :requests, :category, :school_id, :privacy_policy, :recaptcha_token
    )
  end

  def recaptcha_needed_and_invalid?(token)
    token.present? && !verify_recaptcha_token(token)
  end

  def handle_failed_recaptcha
    respond_to do |format|
      format.html do
        @schools = policy_scope(School)
        flash.now[:alert] = 'reCAPTCHA認証に失敗しました。もう一度お試しください。'
        render :new, status: :unprocessable_entity
      end
      format.json { render json: { status: 403, error: 'reCAPTCHAの検証に失敗しました' } }
    end
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
             alert: '問い合わせの作成に失敗'
    end
  end

  def create_json_response
    if @inquiry.save
      send_mail(@inquiry)
      render json: { status: 200 }
    else
      render json: { status: 500, errors: @inquiry.errors.full_messages }
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

  def verify_recaptcha_token(token)
    secret_key = ENV.fetch('RECAPTCHA_SECRET_KEY', nil)
    return false if token.blank? || secret_key.blank?

    uri = URI('https://www.google.com/recaptcha/api/siteverify')
    res = Net::HTTP.post_form(uri, { 'secret' => secret_key, 'response' => token })
    json = JSON.parse(res.body)
    json['success'] == true && json['score'].to_f >= 0.5
  end
 
  def send_mail(inquiry)
    if inquiry.category == 'R'
      InquiryMailer.with(inquiry: @inquiry).setsu_inquiry.deliver_later
    else
      InquiryMailer.with(inquiry: @inquiry).inquiry.deliver_later
    end
  end
end
