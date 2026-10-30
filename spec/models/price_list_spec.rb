# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PriceList do
  context 'when using factory for tests' do
    it 'has a valid member price factory' do
      expect(create(:member_prices)).to be_valid
    end

    it 'has default member prices course cost == key' do
      random_key = [1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50].sample
      expect(create(:member_prices).courses[random_key.to_s]).to eq(random_key)
    end

    it 'has a valid non-member price factory' do
      expect(create(:non_member_prices)).to be_valid
    end

    it 'has default non-member prices course cost == key * 2' do
      random_key = [1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50].sample
      expect(create(:non_member_prices).courses[random_key.to_s]).to eq(random_key * 2)
    end
  end

  it 'sets course costs from form fields on save' do
    random_key = [1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50].sample
    price_list = create(
      :non_member_prices,
      course1: '1',
      course5: '5',
      course10: '10',
      course15: '15',
      course20: '20',
      course25: '25',
      course30: '30',
      course35: '35',
      course40: '40',
      course45: '45',
      course50: '50'
    )
    expect(price_list.courses[random_key.to_s]).to eq(random_key)
  end

  it 'converts string course cost input to integer' do
    price_list = create(:member_prices, course1: '1')
    expect(price_list.courses['1']).to eq(1)
  end

  it 'allows empty course fields' do
    price_list = create(:member_prices, course1: '')
    expect(price_list).to be_valid
  end

  it 'sets course cost to nil if left empty' do
    price_list = create(:member_prices, course1: '')
    expect(price_list.courses['1']).to be_nil
  end

  describe 'regular-day afternoon price' do
    it 'defaults to disabled and accepts a blank value' do
      price_list = create(:member_prices)
      expect(price_list.regular_day_afternoon_price).to be_nil
      price_list.update!(regular_day_afternoon_price: '')
      expect(price_list.reload.regular_day_afternoon_price).to be_nil
    end

    it 'preserves package prices when only the optional afternoon price is updated or cleared' do
      price_list = create(:member_prices)
      courses = price_list.courses
      price_list.reload.update!(regular_day_afternoon_price: 2700)
      expect(price_list.reload.courses).to eq(courses)
      price_list.update!(regular_day_afternoon_price: nil)
      expect(price_list.reload.courses).to eq(courses)
    end

    [-1, 2700.5, 'invalid', 2_147_483_648].each do |price|
      it "rejects an invalid afternoon price of #{price.inspect}" do
        price_list = build(:member_prices, regular_day_afternoon_price: price)
        expect(price_list).not_to be_valid
        expect(price_list.errors[:regular_day_afternoon_price]).not_to be_empty
      end
    end
  end
end
