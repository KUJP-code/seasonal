# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PriceList do
  subject(:member_prices) { create(:member_prices) }

  context 'when valid' do
    it 'saves' do
      valid_list = build(:member_prices)
      valid = valid_list.save!
      expect(valid).to be true
    end
  end

  context 'when invalid' do
    it 'no course data' do
      no_course = build(:member_prices, courses: nil)
      valid = no_course.save
      expect(valid).to be false
    end
  end

  context 'with course data' do
    it 'can de-serialise into hash' do
      ten_price = member_prices.courses['10']
      expect(ten_price).to be 33_000
    end
  end

  context 'with events' do
    let(:events) { create_list(:event, 2, member_prices_id: member_prices.id) }

    it 'knows its events' do
      list_events = member_prices.events
      expect(list_events).to match_array(events)
    end

    it 'events know it' do
      know_event = events.all? { |event| event.member_prices == member_prices }
      expect(know_event).to be true
    end
  end
end
