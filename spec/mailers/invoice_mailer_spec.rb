# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoiceMailer do
  let(:invoice) { create(:invoice, child: user.children.first || child) }

  context 'when sending confirmation notification' do
    subject(:mail) { described_class.with(invoice:, user:).confirmation_notif }

    let(:user) { create(:user, children: [create(:internal_child)]) }

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

  context 'when sending updated notification (parent updater)' do
    subject(:mail) { described_class.with(invoice:, user:).updated_notif }

    let(:user) { create(:user, children: [create(:internal_child)]) }

    before do
      invoice.versions.new(whodunnit: user.id)
    end

    it 'has booking made subject' do
      expect(mail.subject)
        .to match(I18n.t('invoice_mailer.updated_notif.booking_made'))
    end

    it 'sends an email' do
      expect { mail.deliver_now }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'includes child name in body' do
      expect(mail.html_part.body).to match(user.children.first.name)
    end
  end

  context 'when sending updated notification (sm updater)' do
    subject(:mail) { described_class.with(invoice:, user:).updated_notif }

    let(:user) { create(:user, :school_manager) }
    let(:child) { create(:internal_child, parent: create(:user, :customer)) }

    it 'has invoice updated subject' do
      expect(mail.subject)
        .to match(I18n.t('invoice_mailer.updated_notif.invoice_updated'))
    end

    it 'sends an email' do
      expect { mail.deliver_now }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'includes child name in body' do
      expect(mail.html_part.body).to match(child.name)
    end
  end

  context 'when sending SM updated notification' do
    subject(:mail) { described_class.with(invoice:, user:).sm_updated_notif }

    let(:user) { create(:user, children: [create(:internal_child)]) }

    it 'sends an email' do
      expect { mail.deliver_now }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'includes child name in body' do
      expect(mail.html_part.body).to match(user.children.first.name)
    end
  end
end
