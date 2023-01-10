# frozen_string_literal: true

# Everything here applies to and is accessible from the whole app
class ApplicationController < ActionController::Base
  # Make sure we're in the right language and know who's making changes
  before_action :switch_locale, :set_paper_trail_whodunnit

  private

  def switch_locale
    locale = params[:locale] || I18n.default_locale
    I18n.locale = locale
  end

  def default_url_options
    { locale: I18n.locale }
  end
end
