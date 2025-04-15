# frozen_string_literal: true

class QuickBookingMailer < ApplicationMailer
  def notify_manager(quick_booking)
    @quick_booking = quick_booking
    manager_email = quick_booking.school.manager_email || "p-jayson@kids-up.jp"
    mail(to: manager_email, subject: "New Quick Booking Received")
  end

  def confirmation(quick_booking)
    @quick_booking = quick_booking
    mail(
      to: quick_booking.email,
      subject: "[#{quick_booking.event.name}パーティー] のご予約ありがとうございます"
    )
  end
end
