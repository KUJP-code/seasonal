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
    mail(
      to: @inquiry.email,
      bcc: @recipients,
      subject: "【KidsUP#{@school.name}校】 無料体験レッスンのご予約ありがとうございます"
    )
  end

  private

  def set_shared_vars
    @inquiry = params[:inquiry]
    @school = @inquiry.school
    @recipients = ['hq@kids-up.jp'] + @school.managers.pluck(:email)
  end
end
