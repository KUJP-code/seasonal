# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecruitTrackingLinkPolicy do
  describe '#index?' do
    let(:record) { build(:recruit_tracking_link) }

    it 'allows admin' do
      expect(described_class.new(build(:admin), record).index?).to be(true)
    end

    it 'forbids statistician' do
      expect(described_class.new(build(:statistician), record).index?).to be(false)
    end
  end

  describe '#create?' do
    let(:record) { build(:recruit_tracking_link) }

    it 'allows admin' do
      expect(described_class.new(build(:admin), record).create?).to be(true)
    end

    it 'forbids school manager' do
      expect(described_class.new(build(:school_manager), record).create?).to be(false)
    end
  end

  describe 'scope' do
    before { create_list(:recruit_tracking_link, 2) }

    it 'returns all for admin' do
      expect(Pundit.policy_scope!(build(:admin), RecruitTrackingLink).count).to eq(2)
    end

    it 'returns none for customer' do
      expect(Pundit.policy_scope!(build(:customer), RecruitTrackingLink)).to be_empty
    end
  end
end
