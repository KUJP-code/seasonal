# frozen_string_literal: true

require 'rails_helper'

describe EventPolicy do
  subject(:policy) { described_class.new(user, event) }

  let(:event) { create(:event) }

  context 'when admin' do
    let(:user) { build(:admin) }

    it_behaves_like 'authorized except destroy'
  end

  context 'when area manager' do
    let(:user) { build(:area_manager) }

    it_behaves_like 'viewer'

    it 'can access attendance for area events' do
      user.managed_areas << event.area
      user.save
      expect(policy).to authorize_action(:attendance)
    end

    it { is_expected.not_to authorize_action(:attendance) }
  end

  context 'when school manager' do
    let(:user) { build(:school_manager) }

    it_behaves_like 'viewer'

    it 'can access attendance for school events' do
      user.managed_schools << event.school
      user.save
      expect(policy).to authorize_action(:attendance)
    end

    it { is_expected.not_to authorize_action(:attendance) }
  end

  context 'when statistician' do
    let(:user) { build(:statistician) }

    it_behaves_like 'unauthorized user'
    it { is_expected.not_to authorize_action(:attendance) }
  end

  context 'when customer' do
    let(:user) { create(:customer) }

    it_behaves_like 'viewer'
    it { is_expected.not_to authorize_action(:index) }
    it { is_expected.not_to authorize_action(:attendance) }
  end

  context 'when resolving scopes' do
    let(:events) { create_list(:event, 3) }

    it 'resolves admin to all events' do
      user = build(:admin)
      expect(Pundit.policy_scope!(user, Event)).to eq(Event.all)
    end

    it 'resolves area_manager to area events' do
      user = create(:area_manager)
      user.managed_areas << create(:area)
      area_event = create(:event)
      area_school = create(:school, area: user.managed_areas.first)
      area_school.events << area_event
      expect(Pundit.policy_scope!(user, Event)).to eq([area_event])
    end

    it 'resolves school_manager to school events' do
      user = create(:school_manager)
      user.managed_schools << create(:school)
      expect(Pundit.policy_scope!(user, Event.all)).to eq(user.school_events)
    end

    it 'resolves statistician to all events' do
      user = build(:statistician)
      expect(Pundit.policy_scope!(user, Event.all)).to eq(Event.all)
    end

    it 'resolves customer to events children are attending' do
      user = build(:customer)
      expect(Pundit.policy_scope!(user, Event.all)).to eq(user.events)
    end
  end
end
