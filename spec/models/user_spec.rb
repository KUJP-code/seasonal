# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User' do
  let(:valid_user) { build(:user) }
  let(:user) { create(:user) }

  context 'when valid' do
    it 'saves the User' do
      saves = valid_user.save
      expect(saves).to be true
    end

    it 'role is customer by default' do
      role = user.role
      expect(role).to eq 'customer'
    end
  end

  context 'when role is specified' do
    it 'sets role as customer' do
      role = create(:customer_user).role
      expect(role).to eq 'customer'
    end

    it 'sets role as school manager' do
      role = create(:sm_user).role
      expect(role).to eq 'school_manager'
    end

    it 'sets role as area manager' do
      role = create(:am_user).role
      expect(role).to eq 'area_manager'
    end

    it 'sets role as admin' do
      role = create(:admin_user).role
      expect(role).to eq 'admin'
    end

    it 'can be confirmed with #customer?' do
      confirmable = create(:customer_user).customer?
      expect(confirmable).to be true
    end

    it 'can be confirmed with #school_manager?' do
      confirmable = create(:sm_user).school_manager?
      expect(confirmable).to be true
    end

    it 'can be confirmed with #area_manager?' do
      confirmable = create(:am_user).area_manager?
      expect(confirmable).to be true
    end

    it 'can be confirmed with #admin?' do
      confirmable = create(:admin_user).admin?
      expect(confirmable).to be true
    end
  end

  context 'when password is invalid' do
    it 'rejects passwords shorter than 10 characters' do
      short_pass = build(:user, password: 'short')
      valid = short_pass.save
      expect(valid).to be false
    end

    it 'rejects users with no password' do
      no_pass = build(:user, password: 'nil')
      valid = no_pass.save
      expect(valid).to be false
    end
  end

  context 'when email is invalid' do
    it 'rejects users with no email' do
      no_email = build(:user, email: 'nil')
      valid = no_email.save
      expect(valid).to be false
    end
  end

  context 'with association' do
    context 'when regular user' do
      # it 'knows which area it belongs to' do
      #   area = create(:area)
      #   area_user = create(:user, area: area)
      #   user_area = area_user.area
      #   expect(user_area).to be area
      # end

      it "doesn't need a managed area" do
        no_managing = build(:user, managed_area: nil)
        no_managing_valid = no_managing.save
        expect(no_managing_valid).to be true
      end

      xit 'knows its school' do
      end

      xit 'knows its area through school' do
      end
    end

    context 'when area manager' do
      it 'knows its area' do
        attrs = attributes_for(:area, manager: nil)
        managed_area = user.create_managed_area(attrs)
        user_area = user.managed_area
        expect(user_area).to be managed_area
      end

      xit "doesn't need a school" do
      end
    end

    context 'when school manager' do
      xit 'knows its school' do
        attrs = attributes_for(:school, manager: nil)
        managed_school = user.create_managed_school(attrs)
        user_school = user.managed_school
        expect(user_school).to be managed_school
      end

      xit "doesn't need a school" do
      end
    end
  end
end
