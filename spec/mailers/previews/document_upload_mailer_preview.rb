# frozen_string_literal: true

require 'factory_bot_rails'

class DocumentUploadMailerPreview < ActionMailer::Preview
  include FactoryBot::Syntax::Methods

  def sm_notification
    DocumentUploadMailer
      .with(document_upload: create(:document_upload))
      .sm_notification
  end
end
