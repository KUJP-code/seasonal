# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InquiryMailer do
  context 'when setsumeikai inquiry' do
    subject(:mail) { described_class.with(inquiry:).setsu_inquiry }

    let(:inquiry) { create(:setsumeikai_inquiry) }

    it 'sends an email' do
      expect { mail.deliver_now }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'includes student ele school in body' do
      expect(mail.html_part.body).to match(inquiry.ele_school)
    end
  end

  context 'when general inquiry' do
    subject(:mail) { described_class.with(inquiry:).inquiry }

    let(:inquiry) { create(:inquiry) }

    it 'sends an email' do
      expect { mail.deliver_now }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'includes child grade in body' do
      expect(mail.html_part.body).to match(inquiry.child_grade)
    end
  end
end
