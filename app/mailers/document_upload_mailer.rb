# frozen_string_literal: true

class DocumentUploadMailer < ApplicationMailer
  default from: 'documents@kids-up.app',
          'List-Unsubscribe-Post' => 'List-Unsubscribe=One-Click',
          'List-Unsubscribe' => 'https://kids-up.app/mailer_subscriptions'

  def sm_notification
    @document_upload = params[:document_upload]
    mail to: @document_upload.school.managers.pluck(:email),
         subject: '新しい書類を受け取りました'
  end
end
