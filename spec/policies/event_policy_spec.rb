# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'viewer for EventPolicy' do
  it { is_expected.to authorize_action(:index) }
  it { is_expected.to authorize_action(:show) }
end

RSpec.shared_examples 'user unauthorized to change Events' do
  it { is_expected.not_to authorize_action(:new) }
  it { is_expected.not_to authorize_action(:create) }
  it { is_expected.not_to authorize_action(:edit) }
  it { is_expected.not_to authorize_action(:update) }
  it { is_expected.not_to authorize_action(:destroy) }
end

RSpec.shared_examples 'user unauthorized to view attendance' do
  it { is_expected.not_to authorize_action(:attendance) }
end

describe EventPolicy do
  subject(:policy) { described_class.new(user, event) }

  let(:event) { create(:event) }

  context 'when admin' do
    let(:user) { build(:admin) }

    it_behaves_like 'viewer for EventPolicy'

    it { is_expected.to authorize_action(:attendance) }
    it { is_expected.to authorize_action(:new) }
    it { is_expected.to authorize_action(:create) }
    it { is_expected.to authorize_action(:edit) }
    it { is_expected.to authorize_action(:update) }
    it { is_expected.not_to authorize_action(:destroy) }
  end

  context 'when area manager' do
    let(:user) { build(:area_manager) }

    it_behaves_like 'viewer for EventPolicy'
    it_behaves_like 'user unauthorized to change Events'

    it 'can access attendance for area events' do
      user.managed_areas << event.area
      user.save
      expect(policy).to authorize_action(:attendance)
    end

    it 'cannot access attendance for events outside managed areas' do
      expect(policy).not_to authorize_action(:attendance)
    end
  end

  context 'when school manager' do
    let(:user) { build(:school_manager) }

    it_behaves_like 'viewer for EventPolicy'
    it_behaves_like 'user unauthorized to change Events'

    it 'can access attendance for school events' do
      user.managed_schools << event.school
      user.save
      expect(policy).to authorize_action(:attendance)
    end

    it 'cannot access attendance for events at other schools' do
      expect(policy).not_to authorize_action(:attendance)
    end
  end

  context 'when statistician' do
    let(:user) { build(:statistician) }

    it { is_expected.not_to authorize_action(:index) }
    it { is_expected.not_to authorize_action(:show) }

    it_behaves_like 'user unauthorized to change Events'
    it_behaves_like 'user unauthorized to view attendance'
  end

  context 'when customer' do
    let(:user) { build(:customer) }
    let(:child) do
      create(
        :child,
        invoices: [create(:invoice, event: event)]
      )
    end

    before do
      user.children << child
      user.save
      user.events.reload
    end

    it_behaves_like 'viewer for EventPolicy'
    it_behaves_like 'user unauthorized to change Events'
    it_behaves_like 'user unauthorized to view attendance'
  end

  context 'when resolving scopes' do
    let(:events) { create_list(:event, 3) }

    it 'resolves admin to all events' do
      user = build(:admin)
      expect(Pundit.policy_scope!(user, Event.all)).to eq(Event.all)
    end

    it 'resolves area_manager to area events' do
      user = create(:area_manager)
      user.managed_areas << create(:area)
      expect(Pundit.policy_scope!(user, Event.all)).to eq(user.area_events)
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
