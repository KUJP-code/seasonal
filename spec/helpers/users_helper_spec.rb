# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersHelper do
  describe 'name splitting helpers' do
    let(:user) do
      build(:user, name: '廣田　快斗', katakana_name: 'ヒロタ　カイト')
    end

    it 'splits names on full-width spaces' do
      expect(helper.family_name(user)).to eq('廣田')
      expect(helper.first_name(user)).to eq('快斗')
      expect(helper.kana_family(user)).to eq('ヒロタ')
      expect(helper.kana_first(user)).to eq('カイト')
    end

    it 'does not duplicate single-token names into both fields' do
      user.name = '廣田快斗'
      user.katakana_name = 'ヒロタカイト'

      expect(helper.family_name(user)).to eq('廣田快斗')
      expect(helper.first_name(user)).to eq('')
      expect(helper.kana_family(user)).to eq('ヒロタカイト')
      expect(helper.kana_first(user)).to eq('')
    end
  end
end
