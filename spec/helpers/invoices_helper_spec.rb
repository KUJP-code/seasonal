# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoicesHelper do
  include ActiveSupport::Testing::TimeHelpers

  let(:event) do
    build(:event, name: 'ウインタースクール 2026',
                  start_date: Date.new(2026, 12, 14), end_date: Date.new(2027, 2, 8))
  end

  it 'uses the supplied winter wording before the program dates begin' do
    travel_to Time.zone.local(2026, 11, 2) do
      expect(helper.photo_service_copy_scope(event)).to eq('photo_service.winter_2026')
    end
  end

  it 'keeps the supplied wording through the last second of January 7 in Japan' do
    travel_to Time.utc(2027, 1, 7, 14, 59, 59) do
      expect(helper.photo_service_copy_scope(event)).to eq('photo_service.winter_2026')
    end
  end

  it 'switches back at midnight on January 8 in Japan' do
    travel_to Time.utc(2027, 1, 7, 15) do
      expect(helper.photo_service_copy_scope(event)).to eq('photo_service')
    end
  end

  it 'does not apply winter wording to another event during the same period' do
    event.name = 'Other seasonal event'
    travel_to Time.zone.local(2026, 11, 2) do
      expect(helper.photo_service_copy_scope(event)).to eq('photo_service')
    end
  end

  it 'does not reuse the override for a later winter season' do
    event.name = 'ウインタースクール 2027'
    event.start_date = Date.new(2027, 12, 14)
    travel_to Time.zone.local(2027, 11, 2) do
      expect(helper.photo_service_copy_scope(event)).to eq('photo_service')
    end
  end
end
