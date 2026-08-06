# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChildImportJob do
  let(:school) { create(:school, name: '大島') }
  let(:import) { ChildImport.create!(user: create(:admin)) }
  let(:values) do
    [
      '生徒', '12345', '山田 太郎', 'ヤマダ タロウ', 'Taro', '2018/04/02', '小学２年',
      '大島小学校', 'Kids UP 大島校', 'なし', '通学生', 'OK', '有り'
    ]
  end

  before do
    school
    utf8_tsv = CSV.generate(col_sep: "\t") do |csv|
      csv << SsChildRowParser::REQUIRED_HEADERS
      csv << values
    end
    io = StringIO.new(utf8_tsv.encode(Encoding::Windows_31J)).binmode
    import.source_file.attach(io:, filename: 'ss_children.csv', content_type: 'text/csv')
  end

  it 'imports the original CP932 SS export without conversion or splitting' do
    expect { described_class.perform_now(import) }.to change(Child, :count).by(1)

    child = Child.find_by!(ssid: 12_345)
    expect(child).to have_attributes(
      name: '山田 太郎', grade: '小２', school_id: school.id,
      category: 'external', photos: 'OK', own_snack: true,
      received_hat: false
    )
    expect(import.reload).to have_attributes(
      status: 'completed', total_rows: 1, processed_rows: 1,
      created_count: 1, skipped_count: 0, failed_count: 0
    )
  end
end
