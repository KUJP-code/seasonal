# frozen_string_literal: true

require 'rails_helper'

RSpec.describe School do
  let(:valid_school) { build(:school) }
  let(:school) { create(:school) }

  context 'when valid' do
    it 'saves' do
      valid = valid_school.save!
      expect(valid).to be true
    end

    it 'saves with a + in phone number' do
      valid_school.phone = '+815834653453'
      plus_valid = valid_school.save!
      expect(plus_valid).to be true
    end

    it 'saves with spaces in phone number' do
      valid_school.phone = '+8158 3465 3453'
      space_valid = valid_school.save!
      expect(space_valid).to be true
    end
  end

  context 'when invalid' do
    context 'when phone number invalid' do
      it "doesn't accept letters" do
        not_numbers = build(:school, phone: '79ug9723A')
        valid = not_numbers.save
        expect(valid).to be false
      end

      it "doesn't accept symbols other than +" do
        illegal_symbols = build(:school, phone: '79%*9723#')
        valid = illegal_symbols.save
        expect(valid).to be false
      end
    end

    context 'when required associations missing' do
      it "doesn't save without area" do
        valid_school.area = nil
        no_area_valid = valid_school.save
        expect(no_area_valid).to be false
      end

      it "doesn't save without manager" do
        valid_school.manager = nil
        no_manager_valid = valid_school.save
        expect(no_manager_valid).to be false
      end
    end
  end

  # context 'when associated' do
  #   context 'with area' do
  #     it 'knows its area' do
  #       area = create(:area)
  #       new_school = create(:school, area: area)
  #       school_area = new_school.area
  #       expect(school_area).to be area
  #     end
  #   end

  #   context 'with manager' do
  #     it 'knows its manager' do
  #       manager = create(:sm_user)
  #       new_school = create(:school, manager: manager)
  #       school_manager = new_school.manager
  #       expect(school_manager).to be manager
  #     end
  #   end

  #   context 'with users' do
  #     it 'knows its users' do
  #       users = build_list(:user, 10)
  #       school.users.create(users)
  #       school_users = school.users
  #       expect(school_users).to eq users
  #     end
  #   end
  # end
end
