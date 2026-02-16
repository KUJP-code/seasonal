# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecruitTrackingLink do
  it 'has a valid factory' do
    expect(build(:recruit_tracking_link)).to be_valid
  end

  it 'normalizes slug to lowercase' do
    link = create(:recruit_tracking_link, slug: 'My-Link')

    expect(link.slug).to eq('my-link')
  end

  it 'rejects invalid slug format' do
    link = build(:recruit_tracking_link, slug: 'Bad Slug')

    expect(link).not_to be_valid
    expect(link.errors[:slug]).to be_present
  end

  it 'rejects duplicate slugs' do
    create(:recruit_tracking_link, slug: 'unique-link')
    duplicate = build(:recruit_tracking_link, slug: 'unique-link')

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:slug]).to be_present
  end
end
