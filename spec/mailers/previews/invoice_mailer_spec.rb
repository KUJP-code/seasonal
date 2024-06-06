# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoiceMailer do
  context 'when sending confirmation notification' do
    subject(:mail) { described_class.with(invoice:, user:).confirmation_notif }

    let(:user) { create(:user, children: [create(:internal_child)]) }
    let(:invoice) { create(:invoice, child: user.children.first) }

    it 'sends an email' do
      expect { mail.deliver_now }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'includes parent name in body' do
      expect(mail.html_part.body).to match(user.name)
    end

    it 'has an attached confirmation pdf' do
      attachment = mail.attachments.first
      expected_type = 'application/pdf; filename=invoice.pdf'
      expect(attachment.content_type).to eq(expected_type)
    end
  end
end
