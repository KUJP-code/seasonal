# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Coupon do
  subject(:slot_coupon) { create(:slot_coupon) }

  let(:time_slot) { create(:time_slot) }
  let(:option) { create(:option) }

  context 'when valid' do
    context 'when for time slot' do
      it 'time slot coupon saves' do
        valid_coupon = time_slot.coupons.build(attributes_for(:coupon))
        valid = valid_coupon.save!
        expect(valid).to be true
      end

      it 'knows its couponable time slot' do
        valid_coupon = time_slot.coupons.build(attributes_for(:coupon))
        coupon_slot = valid_coupon.couponable
        expect(coupon_slot).to eq time_slot
      end
    end

    context 'when for option' do
      it 'option coupon saves' do
        valid_coupon = option.coupons.build(attributes_for(:coupon))
        valid = valid_coupon.save!
        expect(valid).to be true
      end

      it 'knows its couponable option' do
        valid_coupon = option.coupons.build(attributes_for(:coupon))
        coupon_slot = valid_coupon.couponable
        expect(coupon_slot).to eq option
      end
    end
  end

  context 'with scopes' do
    let(:slot_coupon) { time_slot.coupons.create(attributes_for(:coupon)) }
    let(:option_coupon) { option.coupons.create(attributes_for(:coupon)) }

    it 'knows which coupons are for time slots' do
      option_coupon
      slot_coupons = described_class.slot_coupons
      expect(slot_coupons).to contain_exactly(slot_coupon)
    end

    it 'knows which coupons are for options' do
      slot_coupon
      option_coupons = described_class.option_coupons
      expect(option_coupons).to contain_exactly(option_coupon)
    end
  end
end
