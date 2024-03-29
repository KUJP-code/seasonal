# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'manager for TimeSlotPolicy' do
  it { is_expected.to authorize_action(:index) }
  it { is_expected.not_to authorize_action(:new) }
  it { is_expected.not_to authorize_action(:edit) }
end

RSpec.shared_examples 'school manager for TimeSlotPolicy' do
  it { is_expected.not_to authorize_action(:update) }
end

RSpec.shared_examples 'area manager for TimeSlotPolicy' do
  it { is_expected.to authorize_action(:update) }
end

RSpec.shared_examples 'unauthorized user for TimeSlotPolicy' do
  it { is_expected.not_to authorize_action(:index) }
  it { is_expected.not_to authorize_action(:new) }
  it { is_expected.not_to authorize_action(:edit) }
  it { is_expected.not_to authorize_action(:update) }
  it { is_expected.not_to authorize_action(:attendance) }
end

RSpec.describe TimeSlotPolicy do
  subject(:policy) { described_class.new(user, time_slot) }

  let(:time_slot) { build(:time_slot) }

  context 'when admin' do
    let(:user) { build(:admin) }

    it_behaves_like 'authorized except destroy'
  end

  context 'when area manager' do
    let(:user) { build(:area_manager) }

    context 'when manager of TimeSlot school area' do
      before do
        time_slot.save
        user.managed_areas << time_slot.school.area
        user.save
      end

      it { is_expected.to authorize_action(:attendance) }
      it { is_expected.to authorize_action(:show) }
      it { is_expected.not_to authorize_action(:new) }
      it { is_expected.not_to authorize_action(:edit) }
      it { is_expected.not_to authorize_action(:create) }
      it { is_expected.to authorize_action(:update) }
      it { is_expected.not_to authorize_action(:destroy) }
    end

    context 'when manager of different area' do
      it_behaves_like 'unauthorized user'
    end
  end

  context 'when school manager' do
    let(:user) { build(:school_manager) }

    context 'when manager of TimeSlot school' do
      before do
        time_slot.save
        user.managed_schools << time_slot.school
        user.save
      end

      it_behaves_like 'viewer'
      it { is_expected.to authorize_action(:attendance) }
    end

    context 'when manager of different school' do
      it_behaves_like 'unauthorized user'
      it { is_expected.not_to authorize_action(:attendance) }
    end
  end

  context 'when statistician' do
    let(:user) { build(:statistician) }

    it_behaves_like 'unauthorized user'
  end

  context 'when customer' do
    let(:user) { build(:customer) }

    it_behaves_like 'unauthorized user'
  end

  context 'when resolving scopes' do
    let(:time_slots) { create_list(:time_slot, 2) }

    it 'resolves admin to all time slots' do
      user = build(:admin)
      expect(Pundit.policy_scope!(user, TimeSlot)).to eq(time_slots)
    end

    it 'resolves area_manager to area time slots' do
      user = create(:area_manager)
      user.managed_areas << create(:area)
      school = create(:school, area: user.managed_areas.first)
      area_slots = create_list(:time_slot, 3, school: school)
      expect(Pundit.policy_scope!(user, TimeSlot)).to eq(area_slots)
    end

    it 'resolves school_manager to school time slots' do
      user = create(:school_manager)
      user.managed_schools << create(:school)
      school_slots = create_list(:time_slot, 3, school: user.managed_school)
      expect(Pundit.policy_scope!(user, TimeSlot)).to eq(school_slots)
    end

    it 'resolves statistician to nothing' do
      user = build(:statistician)
      expect(Pundit.policy_scope!(user, TimeSlot)).to eq(TimeSlot.none)
    end

    it 'resolves parent to nothing' do
      user = build(:customer)
      expect(Pundit.policy_scope!(user, TimeSlot)).to eq(TimeSlot.none)
    end
  end
end
