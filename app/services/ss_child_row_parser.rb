# frozen_string_literal: true

class SsChildRowParser
  class SkippedRow < StandardError; end

  REQUIRED_HEADERS = %w[
    ステータス 生徒コード 生徒名 生徒名カナ 生徒ニックネーム 生年月日 学年 勤務先／学校名
    担当校舎 アレルギー項目 生徒種別 写真掲載 スナック持参有無
  ].freeze

  def initialize(schools: School.all)
    @schools = schools.index_by { |school| normalize_school(school.name) }
  end

  # rubocop:disable Metrics/AbcSize
  def call(row)
    raise SkippedRow, row['ステータス'].to_s.strip unless row['ステータス'].to_s.strip == '生徒'

    birthday = parse_date(required(row, '生年月日'))
    attributes = {
      ssid: required(row, '生徒コード'),
      name: presence_or(row['生徒名'], 'なし'),
      katakana_name: normalize_katakana(presence_or(row['生徒名カナ'], 'ナシ')),
      en_name: presence_or(row['生徒ニックネーム'], 'なし'),
      birthday:,
      grade: parse_grade(row['学年']),
      ele_school_name: row['勤務先／学校名'].to_s.strip,
      allergies: presence_or(row['アレルギー項目'], 'Unknown'),
      category: parse_category(required(row, '生徒種別')),
      photos: parse_photos(value(row, '写真掲載')),
      own_snack: parse_boolean(value(row, 'スナック持参有無'))
    }
    school = parse_school(required(row, '担当校舎'))
    attributes[:school_id] = school.id if school
    attributes
  end
  # rubocop:enable Metrics/AbcSize

  private

  def required(row, header)
    result = value(row, header).to_s.strip
    raise ArgumentError, "#{header} is blank" if result.blank?

    result
  end

  def value(row, header)
    row[header] || row["\uFEFF#{header}"]
  end

  def presence_or(value, fallback)
    value.to_s.strip.presence || fallback
  end

  def normalize_katakana(value)
    value.to_s.tr('　', ' ').strip
  end

  def parse_date(value)
    Date.parse(value.to_s.tr('年月', '--').delete('日'))
  rescue Date::Error
    raise ArgumentError, "Invalid 生年月日: #{value}"
  end

  def parse_grade(value)
    normalized = value.to_s.strip.tr('0-9', '０-９').delete_suffix('生')
    aliases = {
      '年少々' => '年々少', '幼児' => '年少',
      '小学１年' => '小１', '小学２年' => '小２', '小学３年' => '小３',
      '小学４年' => '小４', '小学５年' => '小５', '小学６年' => '小６'
    }
    grade = aliases.fetch(normalized, normalized)
    return '中学２年' if grade.in?(['', '中学３年', '高校生以上'])
    return grade if Child.grades.key?(grade)

    raise ArgumentError, "Unknown 学年: #{value}"
  end

  def parse_school(value)
    @schools[normalize_school(value)]
  end

  def normalize_school(value)
    normalized = value.to_s.unicode_normalize(:nfkc).downcase
                      .gsub(/kids\s*up|[校舎\s　]/i, '')
    normalized == 'テスト' ? 'test' : normalized
  end

  def parse_category(value)
    normalized = value.to_s.unicode_normalize(:nfkc).strip.downcase
    internal = %w[内部生 休会オンライン生 オンライン生 休会生]
    reservations = ['予約生', '◆キャンセル待ち（予約生）']
    return 'internal' if normalized.in?(internal)
    return 'reservation' if normalized.in?(reservations)

    'external'
  end

  def parse_photos(value)
    normalized = value.to_s.unicode_normalize(:nfkc).strip
    return 'NG' if normalized == '全てNG'
    return 'マイページOK' if normalized == 'マイページのみOK'
    return 'Unknown' if normalized.blank?

    'OK'
  end

  def parse_boolean(value)
    normalized = value.to_s.unicode_normalize(:nfkc).strip
    return false if normalized.blank? || normalized.match?(/^(0|false|no|n|無|無し|なし|不要|×)$/i)
    return true if normalized.match?(/^(1|true|yes|y|own snack|有|有り|あり|持参|必要|○)$/i)

    raise ArgumentError, "Unknown スナック持参有無: #{value}"
  end
end
