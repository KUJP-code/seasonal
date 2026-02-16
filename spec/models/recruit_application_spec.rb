# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecruitApplication do
  it 'has a valid factory' do
    expect(build(:recruit_application)).to be_valid
  end

  it 'accepts canonical role values' do
    application = build(:recruit_application, role: 'bilingual')

    expect(application).to be_valid
    expect(application.role).to eq('bilingual')
  end

  it 'rejects non-canonical role values' do
    application = build(:recruit_application, role: 'バイリンガル')

    expect(application).not_to be_valid
    expect(application.errors[:role]).to be_present
  end

  it 'requires required fields' do
    application = build(:recruit_application,
                        email: nil,
                        phone: nil,
                        full_name: nil,
                        date_of_birth: nil,
                        full_address: nil,
                        privacy_policy_consent: false)

    expect(application).not_to be_valid
    expect(application.errors[:email]).to be_present
    expect(application.errors[:phone]).to be_present
    expect(application.errors[:full_name]).to be_present
    expect(application.errors[:date_of_birth]).to be_present
    expect(application.errors[:full_address]).to be_present
    expect(application.errors[:privacy_policy_consent]).to be_present
  end

  it 'sets default privacy policy url' do
    application = create(:recruit_application, privacy_policy_url: nil)

    expect(application.privacy_policy_url).to eq(RecruitApplication::PRIVACY_POLICY_URL)
  end

  it 'rejects unknown tracking link slugs' do
    application = build(:recruit_application, tracking_link_slug: 'missing-slug')

    expect(application).not_to be_valid
    expect(application.errors[:tracking_link_slug]).to be_present
  end
end
