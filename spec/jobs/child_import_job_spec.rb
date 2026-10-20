# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChildImportJob do
  include ActiveSupport::Testing::TimeHelpers

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

  shared_examples 'a stable imported grade' do |source_grade, stored_grade|
    let(:values) do
      super().tap do |row|
        row[5] = '2008/04/02'
        row[6] = source_grade
      end
    end

    it 'keeps the grade when another imported field changes and skips a repeat import' do
      child = create(:child, ssid: 12_345, birthday: Date.new(2008, 4, 2),
                             grade: stored_grade, en_name: 'Previous nickname')

      described_class.perform_now(import)

      expect(child.reload).to have_attributes(grade: stored_grade, en_name: 'Taro')
      expect(import.reload).to have_attributes(status: 'completed', updated_count: 1)
      saved_at = child.updated_at
      repeated_import = ChildImport.create!(user: import.user)
      repeated_import.source_file.attach(import.source_file.blob)

      described_class.perform_now(repeated_import)

      expect(child.reload).to have_attributes(grade: stored_grade, updated_at: saved_at)
      expect(repeated_import.reload).to have_attributes(
        status: 'completed', updated_count: 0, unchanged_count: 1, failed_count: 0
      )
    end
  end

  context 'when SS says high school or above' do
    include_examples 'a stable imported grade', '高校生以上', '高校生以上'
  end

  context 'when SS says third-year middle school' do
    include_examples 'a stable imported grade', '中学３年', '高校生以上'
  end

  context 'when SS has no grade' do
    include_examples 'a stable imported grade', nil, '高校生以上'
  end

  context 'when the supplied grade differs from the birthday calculation' do
    include_examples 'a stable imported grade', '中学２年', '中学２年'
  end

  context 'when a new student has no grade in SS' do
    let(:values) { super().tap { |row| row[6] = nil } }

    it 'calculates the grade from the birthday' do
      travel_to Date.new(2026, 10, 20) do
        described_class.perform_now(import)

        expect(Child.find_by!(ssid: 12_345)).to have_attributes(grade: '小２', kindy: false)
        expect(import.reload.status).to eq('completed')
      end
    end
  end

  context 'when the supplied grade matches the database default' do
    let(:values) { super().tap { |row| row[6] = '年少' } }

    it 'keeps the supplied grade for a new student' do
      described_class.perform_now(import)

      expect(Child.find_by!(ssid: 12_345)).to have_attributes(grade: '年少', kindy: true)
    end
  end
end
