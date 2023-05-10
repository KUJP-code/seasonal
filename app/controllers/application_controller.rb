# frozen_string_literal: true

# Everything here applies to and is accessible from the whole app
class ApplicationController < ActionController::Base
  # Enable Pundit on all controllers
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Make sure we're in the right language and know who's making changes
  before_action :switch_locale, :set_paper_trail_whodunnit

  private

  def default_url_options
    { locale: I18n.locale }
  end

  def switch_locale
    locale = params[:locale] || I18n.default_locale
    locale = :en if current_user&.admin?
    I18n.locale = locale
  end

  def user_not_authorized
    flash[:alert] = t('.not_authorized')
    redirect_back(fallback_location: root_path)
  end
end
