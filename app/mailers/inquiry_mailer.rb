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
    @setsumeikai = @inquiry.setsumeikai
    @venue = @setsumeikai.school
    return online_setsu_inquiry if @venue.id == 2

    mail(
      to: @inquiry.email,
      bcc: @recipients,
      subject: "【KidsUP#{@school.name}校】 無料体験レッスンのご予約ありがとうございます"
    )
  end

  def online_setsu_inquiry
    @recipients = ['hq@kids-up.jp'] + @venue.managers.pluck(:email)
    mail(
      to: @inquiry.email,
      bcc: @recipients,
      subject: "【KidsUP#{@venue.name}校】 無料体験レッスンのご予約ありがとうございます",
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
