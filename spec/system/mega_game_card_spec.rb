# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mega Game card', type: :system do
  include ActiveSupport::Testing::TimeHelpers

  SCHOOLS_AND_IMAGES = [
    [26, '北品川', 'mega_game_24.webp'],
    [33, '武蔵新城', 'mega_game_23.webp'],
    [25, '赤羽', 'mega_game_23.webp'],
    [32, '大倉山', 'mega_game_23.webp'],
    [6, '東陽町', 'mega_game_23.webp'],
    [22, '大井', 'mega_game_23.webp'],
    [35, '川口', 'mega_game_24.webp'],
    [5, '池上', 'mega_game_23.webp'],
    [31, '馬込', 'mega_game_24.webp'],
    [10, '成城', 'mega_game_24.webp'],
    [20, '天王町', 'mega_game_23.webp'],
    [3, '田園調布雪谷', 'mega_game_24.webp'],
    [27, '溝の口', 'mega_game_23.webp'],
    [28, '矢向', 'mega_game_23.webp'],
    [11, '大森', 'mega_game_23.webp'],
    [7, '長原', 'mega_game_24.webp'],
    [18, '二俣川', 'mega_game_23.webp'],
    [23, '晴海', 'mega_game_23.webp'],
    [13, 'りんかい東雲', 'mega_game_23.webp'],
    [14, '新川崎', 'mega_game_23.webp'],
    [30, '鷺宮', 'mega_game_24.webp'],
    [36, '池袋', 'mega_game_23.webp'],
    [34, '武蔵小杉', 'mega_game_23.webp'],
    [4, '蒲田駅前', 'mega_game_23.webp'],
    [29, 'ソコラ南行徳', 'mega_game_24.webp'],
    [17, '三鷹', 'mega_game_23.webp'],
    [39, '上野', 'mega_game_23.webp'],
    [21, '南町田グランベリーパーク', 'mega_game_24.webp'],
    [16, '大島', 'mega_game_24.webp'],
    [40, '要町', 'mega_game_24.webp'],
    [12, '早稲田', 'mega_game_24.webp'],
    [9, '戸越', 'mega_game_24.webp'],
    [19, '新浦安', 'mega_game_24.webp'],
    [15, '等々力', 'mega_game_23.webp'],
    [24, '四谷', 'mega_game_24.webp'],
    [8, '門前仲町', 'mega_game_23.webp'],
    [41, '中目黒', 'mega_game_23.webp']
  ].freeze

  let(:parent) { create(:customer) }

  before do
    travel_to Date.new(2026, 5, 23)
    sign_in parent
  end

  after do
    travel_back
    sign_out parent
  end

  it 'shows the mega game card with the correct image for each school' do
    SCHOOLS_AND_IMAGES.each do |school_id, school_name, expected_image|
      school = create(:school, id: school_id, name: school_name)
      child = create(:child, parent:, school:, school_id:)

      visit child_path(id: child.id)

      expect(page).to have_link('Mega Game 2026', href: 'https://my.ptsc.jp/kids-up/entry?i=Mega2026')
      expect(page).to have_content(school_name)
      expect(page).to have_css("img[src*='#{expected_image.delete_suffix('.webp')}']")
    end
  end
end
