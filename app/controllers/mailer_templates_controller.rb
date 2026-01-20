# frozen_string_literal: true

class MailerTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def index
    @previews = ActionMailer::Preview.all.sort_by(&:preview_name).map do |preview|
      {
        name: preview.preview_name,
        emails: preview.emails.sort
      }
    end
  end

  def show
    @preview = ActionMailer::Preview.find(params[:preview])
    raise ActiveRecord::RecordNotFound, 'Mailer preview not found' unless @preview

    @email_action = params[:email]
    @message = @preview.call(@email_action)
  end

  private

  def require_admin
    return if current_user&.admin?

    redirect_to root_path, alert: t('not_authorized')
  end
end
