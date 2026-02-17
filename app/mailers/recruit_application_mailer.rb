# frozen_string_literal: true

class RecruitApplicationMailer < ApplicationMailer
  layout false

  def application_notification
    @recruit_application = params[:recruit_application]

    mail(
      to: @recruit_application.email,
      bcc: recruit_recipients,
      subject: "【Kids UP 採用】応募を受け付けました (#{@recruit_application.role})"
    )
  end

  private

  def recruit_recipients
    recipients = ENV.fetch('RECRUIT_APPLICATION_RECIPIENTS', '')
                    .split(',')
                    .map(&:strip)
                    .reject(&:blank?)

    recipients.presence || %w[r-callan@p-up.jp p-jayson@kids-up.jp]
  end
end
