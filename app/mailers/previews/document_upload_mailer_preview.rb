# frozen_string_literal: true

class DocumentUploadMailerPreview < ActionMailer::Preview
  def sm_notification
    document_upload = DocumentUpload.includes(school: :managers).order(created_at: :desc).find do |upload|
      upload.school&.managers&.exists?
    end

    raise 'No document upload with manager recipients found for preview' unless document_upload

    DocumentUploadMailer
      .with(document_upload:)
      .sm_notification
  end
end
