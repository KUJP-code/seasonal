# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RashimbaInquiryDeliveryJob do
  let(:inquiry) { create(:rashimba_inquiry) }

  before { ActionMailer::Base.deliveries.clear }

  it 'sends separate confirmation and internal mail from Rashimba and records both deliveries' do
    described_class.perform_now(inquiry.id)
    confirmation, notification = ActionMailer::Base.deliveries
    expect(confirmation.to).to eq([inquiry.email])
    expect(notification.to).to eq(['j-kusaka@kids-up.jp'])
    expect(notification.reply_to).to eq([inquiry.email])
    [confirmation, notification].each do |mail|
      expect(mail.from).to eq(['notifications@rashimba.com'])
      expect(mail.bcc).to be_nil
      expect(mail.raise_delivery_errors).to be(true)
    end
    expect(notification.body.decoded).to include(inquiry.company, inquiry.name)
    expect(inquiry.reload.confirmation_sent_at).to be_present
    expect(inquiry.notification_sent_at).to be_present
  end

  it 'uses parent-specific confirmation copy' do
    parent = create(:rashimba_inquiry, :release_notification)
    described_class.perform_now(parent.id)
    confirmation, notification = ActionMailer::Base.deliveries
    expect(confirmation.text_part.body.decoded).to include('お知らせ登録', '2026年12月予定')
    expect(confirmation.body.decoded).not_to include('スポンサー')
    expect(notification.body.decoded).to include('3-5')
  end

  it 'does not resend completed deliveries on a job retry' do
    described_class.perform_now(inquiry.id)
    expect do
      described_class.perform_now(inquiry.id)
    end.not_to change(ActionMailer::Base.deliveries, :size)
  end

  it 'retries the internal notification without repeating the confirmation' do
    inquiry.update!(confirmation_sent_at: Time.current)
    described_class.perform_now(inquiry.id)
    expect(ActionMailer::Base.deliveries.map(&:to)).to eq([['j-kusaka@kids-up.jp']])
  end

  it 'keeps the completed confirmation when the internal delivery fails' do
    mailer = instance_double(ActionMailer::MessageDelivery)
    allow(RashimbaInquiryMailer).to receive(:with).with(inquiry:).and_call_original
    parameterized = RashimbaInquiryMailer.with(inquiry:)
    allow(RashimbaInquiryMailer).to receive(:with).with(inquiry:).and_return(parameterized)
    allow(parameterized).to receive(:notification).and_return(mailer)
    allow(mailer).to receive(:deliver_now).and_raise(Net::SMTPFatalError, 'SMTP unavailable')
    described_class.perform_now(inquiry.id)
    expect(inquiry.reload.confirmation_sent_at).to be_present
    expect(inquiry.notification_sent_at).to be_nil
  end

  it 'safely skips inquiries deleted before delivery' do
    inquiry.destroy!
    expect do
      described_class.perform_now(inquiry.id)
    end.not_to change(ActionMailer::Base.deliveries, :size)
  end
end
