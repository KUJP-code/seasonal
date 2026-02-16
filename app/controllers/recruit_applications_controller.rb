# frozen_string_literal: true

class RecruitApplicationsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  after_action :verify_authorized, only: %i[index show destroy]
  after_action :verify_policy_scoped, only: :index

  def index
    authorize RecruitApplication

    scoped_recruit_applications = policy_scope(RecruitApplication)
    @tracking_link_slugs = RecruitTrackingLink.active.order(:slug).pluck(:slug)

    @recruit_applications = scoped_recruit_applications.latest_first
    @recruit_applications = @recruit_applications.where(role: params[:role]) if role_filter_given?
    @recruit_applications = @recruit_applications.where(tracking_link_slug: params[:tracking_link_slug]) if tracking_link_filter_given?
    @recruit_applications = @recruit_applications.page(params[:page])
  end

  def create
    @recruit_application = RecruitApplication.new(recruit_application_params)
    assign_request_metadata

    if @recruit_application.save
      RecruitApplicationMailer.with(recruit_application: @recruit_application)
                             .application_notification
                             .deliver_later
      render json: success_payload, status: :ok
    else
      render json: { status: 422, errors: @recruit_application.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def show
    @recruit_application = authorize RecruitApplication.find(params[:id])
  end

  def destroy
    @recruit_application = authorize RecruitApplication.find(params[:id])
    @recruit_application.destroy!

    redirect_to recruit_applications_path,
                notice: 'Recruit application deleted'
  end

  private

  def recruit_application_params
    params.require(:recruit_application).permit(
      :role,
      :email,
      :phone,
      :full_name,
      :date_of_birth,
      :full_address,
      :gender,
      :highest_education,
      :employment_history,
      :reason_for_application,
      :nationality,
      :work_visa_status,
      :questions,
      :privacy_policy_consent,
      :privacy_policy_url,
      :utm_source,
      :utm_medium,
      :utm_campaign,
      :utm_term,
      :utm_content,
      :gclid,
      :fbclid,
      :ttclid,
      :tracking_link_slug,
      :tracking_click_id,
      :attribution_method,
      :landing_page_url,
      :referrer_url,
      :locale,
      raw_tracking: {}
    )
  end

  def assign_request_metadata
    @recruit_application.ip_address ||= request.remote_ip
    @recruit_application.user_agent ||= request.user_agent
    @recruit_application.referrer_url ||= request.referer
    @recruit_application.locale ||= params[:locale]
  end

  def role_filter_given?
    params[:role].present? && RecruitApplication::ROLES.include?(params[:role])
  end

  def tracking_link_filter_given?
    params[:tracking_link_slug].present?
  end

  def success_payload
    {
      status: 200,
      message: 'ok',
      thank_you: {
        ja: 'ご応募ありがとうございました。内容を確認のうえ、次のステップに進んでいただく方にのみご連絡させていただきます。あらかじめご了承ください。',
        en: 'Thank you for your application. We will carefully review the applications and contact those who will proceed in our hiring process.'
      }
    }
  end
end
