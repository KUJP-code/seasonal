# frozen_string_literal: true

FactoryBot.define do
  factory :member_prices, class: 'PriceList' do
    name { 'Member Prices' }
    course1 { '1' }
    course3 { '3' }
    course5 { '5' }
    course10 { '10' }
    course15 { '15' }
    course20 { '20' }
    course25 { '25' }
    course30 { '30' }
    course35 { '35' }
    course40 { '40' }
    course45 { '45' }
    course50 { '50' }
  end

  factory :non_member_prices, class: 'PriceList' do
    name { 'Non-Member Prices' }
    course1 { '2' }
    course3 { '6' }
    course5 { '10' }
    course10 { '20' }
    course15 { '30' }
    course20 { '40' }
    course25 { '50' }
    course30 { '60' }
    course35 { '70' }
    course40 { '80' }
    course45 { '90' }
    course50 { '100' }
  end
end
