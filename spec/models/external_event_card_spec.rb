# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalEventCard do
  include ActiveSupport::Testing::TimeHelpers

  describe '.visible_for' do
    let(:school) { create(:school) }
    let(:child) { create(:child, school:) }

    it 'returns active cards inside the date range for the child school' do
      card = create(:external_event_card, schools: [school])
      travel_to Date.new(2026, 5, 20)

      expect(described_class.visible_for(child)).to contain_exactly(card)
    end

    it 'hides cards outside the date range before checking active cards' do
      create(:external_event_card,
             schools: [school],
             starts_on: Date.new(2026, 6, 1),
             ends_on: Date.new(2026, 6, 30))
      travel_to Date.new(2026, 5, 20)

      expect(described_class.visible_for(child)).to be_empty
    end

    it 'hides inactive cards inside the date range' do
      create(:external_event_card, schools: [school], active: false)
      travel_to Date.new(2026, 5, 20)

      expect(described_class.visible_for(child)).to be_empty
    end
  end

  describe '#variant_for' do
    it 'returns the variant assigned to the child school' do
      ikebukuro = create(:school, name: '池袋')
      ojima = create(:school, name: '大島')
      card = build(:external_event_card, schools: [ikebukuro])
      card.variants << build(
        :external_event_card_variant,
        external_event_card: card,
        schools: [ojima],
        event_on: Date.new(2026, 5, 24)
      )
      card.save!
      child = create(:child, school: ojima)

      expect(card.variant_for(child).event_on).to eq(Date.new(2026, 5, 24))
    end
  end

  describe 'validations' do
    it 'does not allow a school to be assigned to multiple variants' do
      school = create(:school)
      card = build(:external_event_card, schools: [school])
      card.variants << build(
        :external_event_card_variant,
        external_event_card: card,
        schools: [school],
        event_on: Date.new(2026, 5, 24)
      )

      expect(card).not_to be_valid
      expect(card.errors.full_messages.join).to include('Schools can only be assigned')
    end
  end
end
