# frozen_string_literal: true

class MonthlyScheduleImport
  HEADERS = ['ssid', *RegularSchedule::WEEKDAYS].freeze
  BOOLEAN_VALUES = {
    'true' => true, 't' => true, '1' => true, 'yes' => true,
    'false' => false, 'f' => false, '0' => false, 'no' => false
  }.freeze

  def initialize(csv, attendance_month)
    raise ArgumentError, 'Choose a schedule CSV file.' unless csv.respond_to?(:tempfile)
    unless attendance_month.to_s.match?(/\A\d{4}-(0[1-9]|1[0-2])\z/)
      raise ArgumentError, 'Choose the attendance month (YYYY-MM).'
    end

    @path = csv.tempfile.path
    @month = Date.strptime(attendance_month, '%Y-%m').beginning_of_month
  end

  def call
    rows = read_rows
    children = Child.where(ssid: rows.filter_map { |row| student_ssid(row) }).index_by(&:ssid)
    seen = {}

    RegularSchedule.transaction do
      rows.each_with_index do |row, index|
        import_row(row, row.fetch('_source_row', index + 2), children, seen)
      end
      clear_omitted_external_schedules(children, seen)
    end
    rows.size
  end

  private

  def read_rows
    rows = CSV.parse(decoded_content.delete_prefix("\uFEFF"), headers: true)
    raise ArgumentError, 'The schedule CSV contains no students.' if rows.empty?

    if Array(rows.headers).intersect?(['対象年月', '生徒情報：生徒コード'])
      return SsScheduleParser.new(rows, @month).call
    end

    missing = HEADERS - Array(rows.headers)
    raise ArgumentError, "Missing schedule columns: #{missing.join(', ')}" if missing.any?

    rows
  end

  def decoded_content
    bytes = File.binread(@path)
    content = bytes.force_encoding(Encoding::UTF_8)
    content.valid_encoding? ? content : bytes.encode(Encoding::UTF_8, Encoding::Windows_31J)
  end

  def import_row(row, line, children, seen)
    ssid = row['ssid'].to_s.strip
    child = children[student_ssid(row)]
    raise ArgumentError, "Row #{line}: unknown student SSID #{ssid.inspect}." unless child
    raise ArgumentError, "Row #{line}: duplicate student SSID #{ssid}." if seen[child.id]

    seen[child.id] = true
    schedule = RegularSchedule.find_or_initialize_by(child:, month: @month)
    schedule.assign_attributes(weekday_attributes(row, line))
    schedule.save! if schedule.changed?
  end

  def student_ssid(row)
    value = row['ssid'].to_s.strip
    value.to_i if value.match?(/\A\d+\z/)
  end

  def clear_omitted_external_schedules(children, seen)
    # Today's membership cannot tell us whether a student attended in a past month.
    return if @month < Time.zone.today.beginning_of_month

    affected_ids = omitted_external_schedule_ids(children, seen)
    weekdays = RegularSchedule::WEEKDAYS.index_with(false)
    existing = RegularSchedule.where(month: @month, child_id: affected_ids).index_by(&:child_id)

    affected_ids.each do |child_id|
      schedule = existing[child_id] || RegularSchedule.new(child_id:, month: @month)
      schedule.assign_attributes(weekdays)
      schedule.save! if schedule.changed?
    end
  end

  def omitted_external_schedule_ids(children, seen)
    school_ids = children.values.filter_map(&:school_id).uniq
    omitted_students = Child.external.where(school_id: school_ids).where.not(id: seen.keys)
    recent_months = (@month - RegularSchedule::FALLBACK_MONTHS.months)..@month
    RegularSchedule.where(month: recent_months, child_id: omitted_students.select(:id))
                   .distinct.pluck(:child_id)
  end

  def weekday_attributes(row, line)
    RegularSchedule::WEEKDAYS.index_with do |day|
      value = row[day].to_s.strip.downcase
      unless BOOLEAN_VALUES.key?(value)
        raise ArgumentError, "Row #{line}: #{day} must explicitly be true or false."
      end

      BOOLEAN_VALUES[value]
    end
  end
end
