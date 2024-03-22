# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'search' do
  let(:user) { create(:admin) }

  before do
    sign_in user
  end

  context 'when searching users' do
    let!(:target) { create(:user, name: 'Tommy boi') }
    let!(:extra) { create(:user) }

    it 'strips leading & trailing whitespace' do
      visit users_path
      within '#users_search' do
        fill_in 'search_name', with: ' Tom'
        click_button I18n.t('shared.search.search')
      end
      expect(page).to have_content(target.name)
      expect(page).not_to have_content(extra.name)
    end

    it 'can search by name for partial match' do
      visit users_path
      within '#users_search' do
        fill_in 'search_name', with: 'Tom'
        click_button I18n.t('shared.search.search')
      end
      expect(page).to have_content(target.name)
      expect(page).not_to have_content(extra.name)
    end
  end

  context 'when searching children' do
    let!(:target) { create(:child, katakana_name: 'カタカナ', ssid: 1_234_567_890) }
    let!(:extra) { create(:child) }

    it 'strips leading & trailing whitespace' do
      visit children_path
      within '#children_search' do
        fill_in 'search_katakana_name', with: 'カタカナ '
        click_button I18n.t('shared.search.search')
      end
      expect(page).to have_content(target.name)
      expect(page).not_to have_content(extra.name)
    end

    it 'can search by katakana name for partial match' do
      visit children_path
      within '#children_search' do
        fill_in 'search_katakana_name', with: 'カタ'
        click_button I18n.t('shared.search.search')
      end
      expect(page).to have_content(target.katakana_name)
      expect(page).not_to have_content(extra.name)
    end

    it 'can search by ssid' do
      visit children_path
      within '#children_search' do
        fill_in 'search_ssid', with: '1234567890'
        click_button I18n.t('shared.search.search')
      end
      expect(page).to have_content(target.name)
      expect(page).not_to have_content(extra.name)
    end
  end
end
