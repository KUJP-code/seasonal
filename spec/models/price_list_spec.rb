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

  it 'sets course costs from form fields on save',
     skip: 'leave for JJ people to do; different way of setting is fine' do
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

  it 'converts string course cost input to integer', skip: 'leave for JJ people to do' do
    price_list = create(:member_prices, course1: '1')
    expect(price_list.courses['1']).to eq(1)
  end
end
