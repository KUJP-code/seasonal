# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecruitApplicationMailer do
  describe '#application_notification' do
    subject(:mail) { described_class.with(recruit_application:).application_notification }

    let(:recruit_application) { create(:recruit_application, role: 'native') }

    it 'renders to applicant and includes role in subject' do
      expect(mail.to).to eq([recruit_application.email])
      expect(mail.subject).to include('native')
    end
  end
end
