# frozen_string_literal: true

# Transactional mail, independent of Kids UP marketing subscription headers and callbacks.
class RashimbaInquiryMailer < ActionMailer::Base # rubocop:disable Rails/ApplicationMailer
  SPONSOR_GUIDE_PATH = Rails.root.join('app/mailers/attachments/rashimba-service-guide.pdf').freeze
  SPONSOR_GUIDE_FILENAME = 'らしんば_サービス案内資料.pdf'
  LOGO_PATH = Rails.root.join('app/mailers/attachments/rashimba-logo.png').freeze

  default from: 'らしんば運営事務局 <notifications@rashimba.com>'
  helper RashimbaInquiryMailerHelper
  layout 'rashimba_mailer', only: :confirmation
  after_action { mail.raise_delivery_errors = true }

  def confirmation
    @inquiry = params[:inquiry]
    options = confirmation_options
    @confirmation_subject = options.fetch(:subject)
    @confirmation_copy = render_to_string(
      template: "rashimba_inquiry_mailer/#{options.fetch(:template_name)}",
      formats: [:text], layout: false
    )
    attachments.inline['rashimba-logo.png'] = {
      mime_type: 'image/png', content: File.binread(LOGO_PATH)
    }
    if @inquiry.sponsor?
      attachments[SPONSOR_GUIDE_FILENAME] = {
        mime_type: 'application/pdf', content: File.binread(SPONSOR_GUIDE_PATH)
      }
    end
    mail(to: @inquiry.email, **options)
  end

  def notification
    @inquiry = params[:inquiry]
    subject = @inquiry.sponsor? ? 'スポンサーのお問い合わせ' : '配信開始のお知らせ登録'
    mail(to: 'j-kusaka@kids-up.jp', reply_to: @inquiry.email, subject: "【らしんば】#{subject}")
  end

  private

  def confirmation_options
    if @inquiry.sponsor?
      {
        reply_to: 'info@rashimba.com',
        subject: '【らしんば】資料請求ありがとうございます（資料を送付いたします）',
        template_name: 'sponsor_confirmation'
      }
    else
      {
        reply_to: 'support@rashimba.com',
        subject: '【らしんば】お知らせ登録ありがとうございます。',
        template_name: 'parent_confirmation'
      }
    end
  end
end
