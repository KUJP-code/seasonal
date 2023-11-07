# frozen_string_literal: true

class InquiryMailer < ApplicationMailer
  def inquiry
    set_shared_vars
    mail(
      to: @recipients,
      subject: "【KidsUP#{@school.name}校】 お問い合わせがありました"
    )
  end

  def setsu_inquiry
    set_shared_vars
    @setsumeikai = @inquiry.setsumeikai
    @venue = @setsumeikai.school
    mail(
      to: @recipients,
      subject: "【KidsUP#{@school.name}校】 説明会予約ありがとうございます"
    )
  end

  private

  def set_shared_vars
    @inquiry = params[:inquiry]
    @school = @inquiry.school
    @recipients = ['hq@kids-up.jp', @school.manager.email, @inquiry.email]
  end
end
