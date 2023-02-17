# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Signup', feature: true do
  let(:new_user) do
    {
      ja_first_name: Faker::Name.first_name,
      ja_family_name: Faker::Name.last_name,
      katakana_name: Faker::Name.name.kana,
      email: Faker::Internet.unique.email,
      password: Faker::Internet.password(min_length: 10),
      address: Faker::Address.full_address,
      phone: Faker::PhoneNumber.phone_number
    }
  end

  def fill_sign_up_info
    within('#new_user') do
      fill_in 'user_email', with: new_user[:email]
      fill_in 'user_email_confirmation', with: new_user[:email]
      fill_in 'user_password', with: new_user[:password]
      fill_in 'user_password_confirmation', with: new_user[:password]
      fill_in 'user_ja_first_name', with: new_user[:ja_first_name]
      fill_in 'user_ja_family_name', with: new_user[:ja_family_name]
      fill_in 'user_katakana_name', with: new_user[:katakana_name]
      select '東京都', from: 'user_prefecture'
      fill_in 'user_address', with: new_user[:address]
      fill_in 'user_postcode', with: new_user[:postcode]
      fill_in 'user_phone', with: new_user[:phone]
    end
  end

  it 'New user signs up' do
    visit '/auth/sign_up'
    fill_sign_up_info
    click_button 'Sign up'

    expect(page).to have_text('My Profile')
  end
end
