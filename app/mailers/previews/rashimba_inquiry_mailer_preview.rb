# frozen_string_literal: true

class RashimbaInquiryMailerPreview < ActionMailer::Preview
  def sponsor_confirmation
    RashimbaInquiryMailer.with(inquiry: sponsor_inquiry).confirmation
  end

  def parent_confirmation
    inquiry = RashimbaInquiry.new(kind: 'release_notification', email: 'preview@example.com')
    RashimbaInquiryMailer.with(inquiry:).confirmation
  end

  private

  def sponsor_inquiry
    RashimbaInquiry.new(
      kind: 'sponsor', company: '株式会社サンプル', name: '山田 太郎', email: 'preview@example.com'
    )
  end
end
