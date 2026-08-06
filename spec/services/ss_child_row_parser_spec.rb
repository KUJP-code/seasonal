# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SsChildRowParser do
  subject(:attributes) { described_class.new(schools: [school]).call(row) }

  let(:school) { build_stubbed(:school, id: 12, name: '大島') }
  let(:row) do
    CSV::Row.new(
      described_class::REQUIRED_HEADERS,
      [
        '生徒', '12345', '山田 太郎', 'ヤマダ タロウ', 'Taro', '2018/04/02', '小学２年',
        '大島小学校', 'Kids UP 大島校', 'なし', '通学生', 'OK', '有り'
      ]
    )
  end

  it 'maps the original Japanese SS columns to child attributes' do
    expect(attributes).to include(
      ssid: '12345', name: '山田 太郎', katakana_name: 'ヤマダ タロウ',
      en_name: 'Taro', birthday: Date.new(2018, 4, 2), grade: '小２',
      ele_school_name: '大島小学校', school_id: 12, allergies: 'なし',
      category: 'external', photos: 'OK', own_snack: true
    )
  end

  it 'leaves an unknown school blank like IFNA VLOOKUP' do
    row['担当校舎'] = '存在しない校'

    expect(attributes).not_to have_key(:school_id)
  end

  it 'skips records whose SS status is not 生徒' do
    row['ステータス'] = '問合せ者'

    expect { attributes }.to raise_error(SsChildRowParser::SkippedRow, '問合せ者')
  end

  it 'maps a blank grade to enum 13 like the spreadsheet' do
    row['学年'] = ''

    expect(attributes[:grade]).to eq('中学２年')
  end

  it 'maps third-year middle school into the oldest supported grade' do
    row['学年'] = '中学３年'

    expect(attributes[:grade]).to eq('中学２年')
  end

  it 'supports every student category present in the SS file' do
    {
      '退会者' => 'external', '予約キャンセル' => 'external',
      '休会生' => 'internal', 'オンライン生' => 'internal', '【使用不可】' => 'external'
    }.each do |ss_value, category|
      row['生徒種別'] = ss_value
      parsed = described_class.new(schools: [school]).call(row)
      expect(parsed[:category]).to eq(category)
    end
  end

  it 'recognizes the SS Own Snack value' do
    row['スナック持参有無'] = 'Own Snack'

    expect(attributes[:own_snack]).to be(true)
  end
end
