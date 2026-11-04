# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retired quick booking' do
  it 'keeps account registration and sign-in available on the landing page' do
    get root_path

    expect(response).to have_http_status(:ok)
    page = Nokogiri::HTML(response.body)
    expect(page.at_css("a[href='#{new_user_registration_path}']")).to be_present
    expect(page.at_css("a[href='#{new_user_session_path}']")).to be_present
    expect(response.body).not_to include('quick_booking', 'quick-booking', '会員登録せずに予約')
  end
end
