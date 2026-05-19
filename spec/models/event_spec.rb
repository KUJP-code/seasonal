# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event do
  context 'when using factory for tests' do
    it 'has a valid factory' do
      expect(build(:event)).to be_valid
    end

    it 'has member prices by default' do
      expect(create(:event).member_prices).to be_present
    end

    it 'has non-member prices by default' do
      expect(create(:event).non_member_prices).to be_present
    end
  end

  it 'rejects goals that will not fit in the column' do
    # This is 1 more than the max value of a 4 bit signed int
    event = build(:event, goal: 2_147_483_648)
    expect(event).not_to be_valid
  end

  describe 'attachment setters' do
    it 'ignores blank image ids' do
      event = create(:event)
      event.image.attach(
        io: StringIO.new('image data'),
        filename: 'event.png',
        content_type: 'image/png'
      )

      original_blob = event.image.blob

      event.update!(image_id: '')

      expect(event.reload.image.blob).to eq(original_blob)
    end

    it 'ignores blank avif ids' do
      event = create(:event)
      event.avif.attach(
        io: StringIO.new('avif data'),
        filename: 'event.avif',
        content_type: 'image/avif'
      )

      original_blob = event.avif.blob

      event.update!(avif_id: '')

      expect(event.reload.avif.blob).to eq(original_blob)
    end
  end

  describe '#pricing_rules_2026?' do
    it 'does not apply to events before May 2026' do
      event = build(:event,
                    start_date: Date.new(2026, 4, 30),
                    end_date: Date.new(2026, 4, 30))

      expect(event).not_to be_pricing_rules_2026
    end

    it 'applies to events starting in May 2026 or later' do
      event = build(:event,
                    start_date: Date.new(2026, 5, 1),
                    end_date: Date.new(2026, 5, 1))

      expect(event).to be_pricing_rules_2026
    end
  end
end
