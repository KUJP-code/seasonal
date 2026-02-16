# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecruitApplicationPolicy do
  describe '#show?' do
    let(:record) { build(:recruit_application) }

    it 'allows admin' do
      expect(described_class.new(build(:admin), record).show?).to be(true)
    end

    it 'allows statistician' do
      expect(described_class.new(build(:statistician), record).show?).to be(true)
    end

    it 'forbids school manager' do
      expect(described_class.new(build(:school_manager), record).show?).to be(false)
    end
  end

  describe '#destroy?' do
    let(:record) { build(:recruit_application) }

    it 'allows admin' do
      expect(described_class.new(build(:admin), record).destroy?).to be(true)
    end

    it 'forbids statistician' do
      expect(described_class.new(build(:statistician), record).destroy?).to be(false)
    end
  end

  describe '#index?' do
    let(:record) { build(:recruit_application) }

    it 'allows admin' do
      expect(described_class.new(build(:admin), record).index?).to be(true)
    end

    it 'allows statistician' do
      expect(described_class.new(build(:statistician), record).index?).to be(true)
    end

    it 'forbids school manager' do
      expect(described_class.new(build(:school_manager), record).index?).to be(false)
    end
  end

  describe 'scope' do
    before { create_list(:recruit_application, 2) }

    it 'returns all for admin' do
      expect(Pundit.policy_scope!(build(:admin), RecruitApplication).count).to eq(2)
    end

    it 'returns none for customer' do
      expect(Pundit.policy_scope!(build(:customer), RecruitApplication)).to be_empty
    end
  end
end
