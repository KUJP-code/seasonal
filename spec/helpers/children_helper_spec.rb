# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChildrenHelper do
  describe 'name splitting helpers' do
    let(:child) do
      build(:child, name: '廣田　快斗', katakana_name: 'ヒロタ　カイト')
    end

    it 'splits names on full-width spaces' do
      expect(helper.family_name(child)).to eq('廣田')
      expect(helper.first_name(child)).to eq('快斗')
      expect(helper.kana_family(child)).to eq('ヒロタ')
      expect(helper.kana_first(child)).to eq('カイト')
    end

    it 'does not duplicate single-token names into both fields' do
      child.name = '廣田快斗'
      child.katakana_name = 'ヒロタカイト'

      expect(helper.family_name(child)).to eq('廣田快斗')
      expect(helper.first_name(child)).to eq('')
      expect(helper.kana_family(child)).to eq('ヒロタカイト')
      expect(helper.kana_first(child)).to eq('')
    end
  end
end
