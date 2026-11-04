# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retired quick-booking routes' do
  [nil, 'ja', 'en'].each do |locale|
    context "with #{locale || 'no'} locale prefix" do
      let(:prefix) { locale ? "/#{locale}" : '' }

      it 'does not accept quick-booking forms or expose the timeslot API' do
        expect(get: "#{prefix}/quick_booking/new").not_to be_routable
        expect(post: "#{prefix}/quick_booking").not_to be_routable
        expect(get: "#{prefix}/quick_booking/thank_you").not_to be_routable
        expect(get: "#{prefix}/schools/3/quick_booking_timeslots.json").not_to be_routable
      end
    end
  end

  it 'removes the old plural booking URL as well' do
    expect(get: '/quick_bookings/new').not_to be_routable
  end
end
