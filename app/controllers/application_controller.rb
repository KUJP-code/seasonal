class ApplicationController < ActionController::Base
  before_action :switch_locale

  private

  def switch_locale
    locale = params[:locale] || I18n.default_locale
    I18n.locale = locale
  end

  def default_url_options
    { locale: I18n.locale }
  end
end
