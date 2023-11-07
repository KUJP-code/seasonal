# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/inquiry
class InquiryPreview < ActionMailer::Preview
  def inquiry
    InquiryMailer.with(
      inquiry: Inquiry.general.order(:created_at).last
    ).inquiry
  end

  def setsu_inquiry
    InquiryMailer.with(
      inquiry: Inquiry.setsumeikai.order(:created_at).last
    ).setsu_inquiry
  end
end
