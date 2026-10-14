# frozen_string_literal: true

class RashimbaInquiryDeliveryJob < ApplicationJob
  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  def perform(inquiry_id)
    inquiry = RashimbaInquiry.find_by(id: inquiry_id)
    return unless inquiry

    deliver(inquiry, :confirmation, :confirmation_sent_at)
    deliver(inquiry, :notification, :notification_sent_at)
  end

  private

  def deliver(inquiry, action, sent_at)
    inquiry.with_lock do
      next if inquiry[sent_at]

      RashimbaInquiryMailer.with(inquiry:).public_send(action).deliver_now
      inquiry.update!(sent_at => Time.current)
    end
  rescue ActiveRecord::RecordNotFound
    # An admin may delete an inquiry before its queued delivery runs.
    nil
  end
end
