# frozen_string_literal: true

# Filter the original SS contract export into one eligible weekday set per student.
class SsScheduleParser
  SLOTS = %w[１ ２ ３ ４ ５].freeze
  COMBINED_COURSE_CODES = %w[414 415 430 431].freeze
  COMBINED_COURSE_SLOTS = %w[２ ４].freeze
  ALLOWED_COURSE_CODES = Rails.application.config_for(:regular_schedule_courses)
                            .fetch(:allowed_course_codes).map(&:to_s).freeze
  DAYS = %w[月 火 水 木 金].zip(RegularSchedule::WEEKDAYS).to_h.freeze
  HEADERS = ['対象年月', '生徒情報：生徒コード', 'コースコード',
             *SLOTS.flat_map { |slot| ["受講日程#{slot}間隔", "受講日程#{slot}曜日"] }].freeze

  def initialize(rows, month)
    @rows = rows
    @month = month
    @month_end = month.end_of_month
  end

  def call
    validate_headers
    if ALLOWED_COURSE_CODES.empty?
      raise ArgumentError, 'SS schedule course codes have not been configured. No schedules were changed.'
    end

    students = grouped_students
    if students.empty?
      raise ArgumentError, 'No eligible attendance courses were found. No schedules were changed.'
    end

    students.each_value { |student| validate_weekdays(student) }
    students.values
  end

  private

  def validate_headers
    missing = HEADERS - Array(@rows.headers)
    raise ArgumentError, "Missing SS schedule columns: #{missing.join(', ')}" if missing.any?
  end

  def grouped_students
    students = {}
    @rows.each_with_index do |row, index|
      line = index + 2
      validate_month(row, line)
      code = row['コースコード'].to_s.strip
      next unless ALLOWED_COURSE_CODES.include?(code)

      validate_dates(row, line)
      ssid = student_ssid(row, line)
      student = students[ssid] ||= empty_schedule(ssid, line)
      add_weekdays(student, row, line, code)
    end
    students
  end

  def validate_weekdays(student)
    return if RegularSchedule::WEEKDAYS.any? { |day| student[day] }

    raise ArgumentError, "Row #{student['_source_row']}: student SSID #{student['ssid']} " \
                         'has no weekly attendance days. ' \
                         'Use an explicit false weekday CSV to clear days.'
  end

  def empty_schedule(ssid, line)
    RegularSchedule::WEEKDAYS.index_with(false)
                             .merge('ssid' => ssid.to_s, '_source_row' => line)
  end

  def student_ssid(row, line)
    value = row['生徒情報：生徒コード'].to_s.strip
    unless value.match?(/\A\d+\z/)
      raise ArgumentError, "Row #{line}: invalid 生徒情報：生徒コード #{value.inspect}."
    end

    value.to_i
  end

  def validate_month(row, line)
    value = row['対象年月'].to_s.strip
    return if value.tr('/', '-') == @month.strftime('%Y-%m')

    raise ArgumentError, "Row #{line}: 対象年月 #{value.inspect} does not match " \
                         "selected attendance month #{@month.strftime('%Y-%m')}."
  end

  def validate_dates(row, line)
    [%w[契約開始日 契約終了日], %w[受講開始日 受講終了日]].each do |start_key, end_key|
      first = parse_date(row[start_key], start_key, line)
      last = parse_date(row[end_key], end_key, line)
      validate_date_range(first, last, "#{start_key}/#{end_key}", line)
    end
  end

  def validate_date_range(first, last, label, line)
    dates = [first, last].compact
    if dates.size == 2 && dates.first > dates.last
      raise ArgumentError, "Row #{line}: #{label} has its start after its end."
    end
    return if (first || @month) <= @month_end && (last || @month_end) >= @month

    raise ArgumentError, "Row #{line}: #{label} does not overlap the attendance month."
  end

  def parse_date(value, header, line)
    return if value.to_s.strip.empty?

    text = value.to_s.strip
    raise Date::Error unless text.match?(%r{\A\d{4}/\d{2}/\d{2}\z})

    Date.strptime(text, '%Y/%m/%d')
  rescue Date::Error
    raise ArgumentError, "Row #{line}: invalid #{header} #{value.inspect}."
  end

  def add_weekdays(student, row, line, code)
    slots = COMBINED_COURSE_CODES.include?(code) ? COMBINED_COURSE_SLOTS : SLOTS
    slots.each do |slot|
      day = row["受講日程#{slot}曜日"].to_s.strip
      interval = row["受講日程#{slot}間隔"].to_s.strip
      next if day.empty? && interval.empty?

      unless interval == '毎週' && DAYS.key?(day)
        raise ArgumentError, "Row #{line}: 受講日程#{slot} must be 毎週 with a weekday 月–金."
      end

      student[DAYS.fetch(day)] = true
    end
  end
end
