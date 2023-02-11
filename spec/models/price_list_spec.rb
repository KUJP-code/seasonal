# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PriceList do
  subject(:member_price) { create(:member_price) }

  context 'when valid' do
    it 'saves' do
      valid_list = build(:member_price)
      valid = valid_list.save!
      expect(valid).to be true
    end
  end

  context 'when invalid' do
    it 'no course data' do
      no_course = build(:member_price, courses: nil)
      valid = no_course.save
      expect(valid).to be false
    end
  end

  context 'with course data' do
    it 'can de-serialise into hash' do
      ten_price = member_price.courses['10']
      expect(ten_price).to be 33_000
    end
  end

  context 'with events' do
    let(:events) { create_list(:event, 2, member_price_id: member_price.id) }

    it 'knows its events' do
      list_events = member_price.events
      expect(list_events).to match_array(events)
    end

    it 'events know it' do
      know_event = events.all? { |event| event.member_price == member_price }
      expect(know_event).to be true
    end
  end
end
