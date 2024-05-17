# frozen_string_literal: true

# Everything here applies to and is accessible from the whole app
class ApplicationController < ActionController::Base
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Make sure we're in the right language and know who's making changes
  before_action :check_sm_ip, :mini_profile, :switch_locale, :set_paper_trail_whodunnit

  private

  # Overwriting the Devise sign_out redirect path method
  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def check_sm_ip
    return unless current_user&.school_manager?
    return if sm_allowed_url? || current_user&.allowed_ips&.include?(request.ip)

    redirect_to user_path(current_user),
                alert: t('not_in_school')
  end

  def sm_allowed_url?
    [user_url(current_user),
     destroy_user_session_url(locale: I18n.locale, _method: :delete)].include?(request.original_url)
  end

  def mini_profile
    Rack::MiniProfiler.authorize_request if current_user&.admin?
  end

  def switch_locale
    locale = params[:locale] || I18n.default_locale
    locale = :en if current_user&.admin?
    I18n.locale = locale
  end

  def user_not_authorized
    redirect_to root_path,
                alert: t('not_authorized')
  end
end
