# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalEventCardPolicy, type: :policy do
  subject(:policy) { described_class.new(user, external_event_card) }

  let(:external_event_card) { build(:external_event_card) }

  context 'with an admin' do
    let(:user) { build(:admin) }

    it { is_expected.to permit_actions(%i[index show new create edit update destroy]) }
  end

  context 'with a customer' do
    let(:user) { build(:customer) }

    it { is_expected.to forbid_actions(%i[index show new create edit update destroy]) }
  end
end
