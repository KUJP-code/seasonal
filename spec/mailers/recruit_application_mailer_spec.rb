# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecruitApplicationMailer do
  describe '#application_notification' do
    subject(:mail) { described_class.with(recruit_application:).application_notification }

    let!(:tracking_link) { create(:recruit_tracking_link, slug: 'test-tracker-15') }

    let(:recruit_application) do
      create(
        :recruit_application,
        role: 'native',
        utm_source: 'tiktok',
        tracking_link_slug: 'test-tracker-15',
        landing_page_url: 'https://kids-up.jp/lp-recruit/apply.php?slug=test-tracker-15'
      )
    end

    it 'renders to applicant and includes role in subject' do
      expect(mail.to).to eq([recruit_application.email])
      expect(mail.subject).to include('native')
    end

    it 'does not include tracking details in body' do
      expect(mail.body.encoded).not_to include('Tracking')
      expect(mail.body.encoded).not_to include('utm_source')
      expect(mail.body.encoded).not_to include('tracking_link_slug')
      expect(mail.body.encoded).not_to include('landing_page_url')
    end
  end
end
