# frozen_string_literal: true

class InquiryMailer < ApplicationMailer
  def inquiry
    set_shared_vars
    mail(
      to: @inquiry.email,
      bcc: @recipients,
      subject: "【KidsUP#{@school.name}校】 お問い合わせがありました"
    )
  end

  def setsu_inquiry
    set_shared_vars
    return online_setsu_inquiry if @school.id == 2

    @setsumeikai = @inquiry.setsumeikai
    @venue = @setsumeikai.school
    mail(
      to: @inquiry.email,
      bcc: @recipients,
      subject: "【KidsUP#{@school.name}校】 無料体験レッスンのご予約ありがとうございます"
    )
  end

  def online_setsu_inquiry
    @setsumeikai = @inquiry.setsumeikai
    mail(
      to: @inquiry.email,
      bcc: @recipients,
      subject: "【KidsUP#{@school.name}校】 無料体験レッスンのご予約ください",
      template_path: 'inquiry_mailer',
      template_name: 'online_setsu_inquiry'
    )
  end

  private

  def set_shared_vars
    @inquiry = params[:inquiry]
    @school = @inquiry.school
    @recipients = ['hq@kids-up.jp'] + @school.managers.pluck(:email)
  end
end
