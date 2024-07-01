# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentUploadMailer do
  subject(:mail) { described_class.with(document_upload:).sm_notification }

  let(:document_upload) { create(:document_upload) }

  it 'sends an email' do
    expect { mail.deliver_now }
      .to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it 'includes the category of document uploaded' do
    expect(mail.html_part.body)
      .to match(I18n.t("document_upload_mailer.#{document_upload.category}"))
  end

  it 'includes a link to the index of document uploads' do
    expect(mail.html_part.body).to match(document_uploads_url)
  end
end
