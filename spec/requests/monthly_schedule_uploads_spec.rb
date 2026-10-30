# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Monthly regular schedule uploads' do
  include ActiveSupport::Testing::TimeHelpers

  let(:admin) { create(:admin) }
  let!(:child) { create(:internal_child, ssid: '123456') }

  before { sign_in admin }

  def upload_schedule(month, rows = "123456,false,true,true,false,false\n")
    Tempfile.create(['schedule', '.csv']) do |file|
      file.write("ssid,monday,tuesday,wednesday,thursday,friday\n#{rows}")
      file.flush
      post update_csv_path, params: {
        model: 'RegularSchedule', attendance_month: month,
        csv: Rack::Test::UploadedFile.new(file.path, 'text/csv')
      }
    end
  end

  def ss_schedule_row(days = [], **overrides)
    row = SsScheduleParser::HEADERS.index_with { '' }.merge(
      '対象年月' => '2026/09', '生徒情報：生徒コード' => child.ssid.to_s,
      'コースコード' => '301',
      '契約開始日' => '2026/09/01', '契約終了日' => '2026/09/30',
      '受講開始日' => '2026/09/01', '受講終了日' => '2026/09/30'
    )
    days.zip(SsScheduleParser::SLOTS).each do |day, slot|
      row["受講日程#{slot}曜日"] = day
      row["受講日程#{slot}間隔"] = '毎週'
    end
    row.merge(overrides.stringify_keys)
  end

  def upload_ss_schedule(rows, month: '2026-09', encoding: 'Windows-31J')
    headers = rows.flat_map(&:keys).uniq
    content = CSV.generate do |csv|
      csv << headers
      rows.each { |row| csv << row.values_at(*headers) }
    end
    content = "\uFEFF#{content}" if encoding == 'UTF-8'
    post_schedule_file(content.encode(encoding), month)
  end

  def post_schedule_file(content, month)
    Tempfile.create(['ss-schedule', '.csv']) do |file|
      file.binmode
      file.write(content)
      file.flush
      post update_csv_path, params: {
        model: 'RegularSchedule', attendance_month: month,
        csv: Rack::Test::UploadedFile.new(file.path, 'text/csv')
      }
    end
  end

  it 'imports original CP932 exports and combines only allowed courses and repeated weekdays once' do
    rows = [
      ss_schedule_row(%w[火 木], 'コースコード' => '301', 'コース名' => '■Main course'),
      ss_schedule_row(%w[火 火 金], 'コースコード' => '309', 'コース名' => 'Additional course'),
      ss_schedule_row(%w[月], 'コースコード' => '505', 'コース名' => 'Monthly 延長'),
      ss_schedule_row([], 'コース名' => '')
    ]
    upload_ss_schedule(rows)

    expect(flash[:alert]).to be_nil
    expect(child.regular_schedules.sole.days).to eq('火, 木, 金')
    expect(child.regular_schedules.sole.month).to eq(Date.new(2026, 9, 1))
  end

  it 'uses only AV and BH for course codes 414, 415, 430 and 431' do
    %w[414 415 430 431].each do |code|
      upload_ss_schedule([ss_schedule_row(%w[月 火 水 木 金], 'コースコード' => code)])

      expect(flash[:alert]).to be_nil
      expect(child.regular_schedules.sole.days).to eq('月, 水')
    end
  end

  it 'imports the Monday attendance rather than the Friday evening lesson for KeepUP' do
    row = ss_schedule_row(%w[月 金], 'コースコード' => '430',
                                    '受講日程１開始時刻' => '13:30',
                                    '受講日程２開始時刻' => '18:15')
    upload_ss_schedule([row])

    expect(flash[:alert]).to be_nil
    expect(child.regular_schedules.sole.days).to eq('月')
  end

  it 'imports every approved course code, including codes absent from the example export' do
    codes = %w[111 112 113 114 115 116 117 118 119 120 121 122 205 206 207 208
               301 302 303 304 305 306 307 308 309 310 414 415 430 431]
    expect(SsScheduleParser::ALLOWED_COURSE_CODES).to match_array(codes)

    codes.each do |code|
      upload_ss_schedule([ss_schedule_row(%w[月 火 水 木 金], 'コースコード' => code)])

      expect(flash[:alert]).to be_nil
      days = %w[414 415 430 431].include?(code) ? '月, 水' : '月, 火, 水, 木, 金'
      expect(child.regular_schedules.sole.days).to eq(days)
    end
  end

  it 'uses AV, BB, BH, BN and BT for other allowed courses and ignores later slots' do
    row = ss_schedule_row(%w[月 火 水 木 金], '受講日程６曜日' => '土', '受講日程６間隔' => '隔週',
                                             '受講日程７曜日' => '日', '受講日程７間隔' => '隔週')
    upload_ss_schedule([row])

    expect(flash[:alert]).to be_nil
    expect(child.regular_schedules.sole.days).to eq('月, 火, 水, 木, 金')
  end

  it 'ignores unsupported weekdays in unused combined-course slots and excluded course rows' do
    upload_ss_schedule([
                         ss_schedule_row(%w[火 土 木 日 土], 'コースコード' => '414',
                                                               '受講日程２間隔' => '隔週'),
                         ss_schedule_row(%w[土], 'コースコード' => '505',
                                               '生徒情報：生徒コード' => 'not-a-student',
                                               '受講開始日' => 'invalid')
                       ])

    expect(flash[:alert]).to be_nil
    expect(child.regular_schedules.sole.days).to eq('火, 木')
  end

  it 'rejects exports containing only excluded courses without clearing existing schedules' do
    travel_to Time.zone.local(2026, 9, 22) do
      child.update!(category: :external)
      schedule = create(:regular_schedule, child:, month: Date.new(2026, 9, 1), monday: true)
      upload_ss_schedule([ss_schedule_row(%w[火], 'コースコード' => '505')])

      expect(flash[:alert]).to include('No eligible attendance courses')
      expect(schedule.reload.days).to eq('月')
    end
  end

  it 'blocks raw exports when the course filter has not been configured' do
    stub_const('SsScheduleParser::ALLOWED_COURSE_CODES', [])
    upload_ss_schedule([ss_schedule_row(%w[火])])

    expect(flash[:alert]).to include('course codes have not been configured')
    expect(child.regular_schedules).to be_empty
  end

  it 'accepts a UTF-8 BOM and uses student codes rather than management IDs' do
    row = ss_schedule_row(%w[水], '生徒情報：管理ＩＤ' => '987654')
    upload_ss_schedule([row], encoding: 'UTF-8')

    expect(flash[:alert]).to be_nil
    expect(child.regular_schedules.sole.days).to eq('水')
  end

  it 'combines leading-zero student codes and corrects only the selected month' do
    create(:regular_schedule, child:, month: Date.new(2026, 10, 1), friday: true)
    upload_ss_schedule([ss_schedule_row(%w[月])])
    upload_ss_schedule([
                         ss_schedule_row(%w[火], '生徒情報：生徒コード' => '00123456'),
                         ss_schedule_row(%w[水])
                       ])

    expect(flash[:alert]).to be_nil
    expect(child.regular_schedules.count).to eq(2)
    expect(child.regular_schedule_for(Date.new(2026, 9, 1)).days).to eq('火, 水')
    expect(child.regular_schedule_for(Date.new(2026, 10, 1)).days).to eq('金')
  end

  it 'rejects files whose month differs from the selection, including mixed months' do
    upload_ss_schedule([ss_schedule_row(%w[月])], month: '2026-10')
    expect(flash[:alert]).to include('does not match selected attendance month 2026-10')

    upload_ss_schedule([
                         ss_schedule_row(%w[月]),
                         ss_schedule_row(%w[火], '対象年月' => '2026/10')
                       ])
    expect(flash[:alert]).to include('Row 3: 対象年月')
    expect(child.regular_schedules).to be_empty
  end

  it 'rejects unsupported recurrence or weekdays without changing existing schedules' do
    create(:regular_schedule, child:, month: Date.new(2026, 9, 1), monday: true)
    [
      ss_schedule_row(%w[火], '受講日程１間隔' => '隔週'),
      ss_schedule_row(%w[土]),
      ss_schedule_row(%w[火], '受講日程１曜日' => '')
    ].each do |row|
      upload_ss_schedule([row])
      expect(flash[:alert]).to include('must be 毎週 with a weekday')
    end
    expect(child.regular_schedules.sole.days).to eq('月')
  end

  it 'rejects invalid, reversed or out-of-month dates' do
    [
      { '受講開始日' => '2026/09/31' },
      { '受講開始日' => '2026/09/25', '受講終了日' => '2026/09/10' },
      { '受講開始日' => '2026/10/01', '受講終了日' => '2026/10/31' }
    ].each do |overrides|
      upload_ss_schedule([ss_schedule_row(%w[火], **overrides)])
      expect(flash[:alert]).to be_present
    end
    expect(child.regular_schedules).to be_empty
  end

  it 'accepts mid-month starts as monthly weekday patterns' do
    upload_ss_schedule([ss_schedule_row(%w[火], '受講開始日' => '2026/09/15')])

    expect(flash[:alert]).to be_nil
    expect(child.regular_schedules.sole.days).to eq('火')
  end

  it 'rejects incomplete exports and fee-only students rather than clearing weekdays' do
    upload_ss_schedule([ss_schedule_row(%w[火]).except('受講日程５曜日')])
    expect(flash[:alert]).to include('Missing SS schedule columns: 受講日程５曜日')

    upload_ss_schedule([ss_schedule_row])
    expect(flash[:alert]).to include('has no weekly attendance days')
    expect(child.regular_schedules).to be_empty
  end

  it 'rolls back a raw export containing unknown or malformed student codes' do
    %w[999999999 123456oops].each do |ssid|
      upload_ss_schedule([
                           ss_schedule_row(%w[火]),
                           ss_schedule_row(%w[水], '生徒情報：生徒コード' => ssid)
                         ])
      expect(flash[:alert]).to be_present
      expect(child.regular_schedules).to be_empty
    end
  end

  it 'offers a required month selector that changes its default on the 21st' do
    [20, 21, 25].each do |day|
      travel_to Time.zone.local(2026, 12, day) do
        sign_out admin
        sign_in admin
        get csvs_path
        expect(response).to have_http_status(:ok)
        field = Nokogiri::HTML(response.body).at_css('input[type="month"][name="attendance_month"]')
        expect(field['value']).to eq(day < 21 ? '2026-12' : '2027-01')
        expect(field['required']).to be_present
      end
    end
  end

  it 'creates the selected month, corrects that month and preserves other months' do
    upload_schedule('2026-12')
    expect(response).to redirect_to(csvs_path)
    expect(flash[:alert]).to be_nil
    upload_schedule('2027-01', "123456,false,false,true,true,false\n")
    upload_schedule('2026-12', "123456,true,false,false,false,false\n")

    expect(child.regular_schedules.count).to eq(2)
    expect(child.regular_schedule_for(Date.new(2026, 12, 1)).days).to eq('月')
    expect(child.regular_schedule_for(Date.new(2027, 1, 1)).days).to eq('水, 木')
  end

  it 'does not guess an attendance month when it is missing or invalid' do
    [nil, '', '2026-13', '2026-12-01'].each do |month|
      upload_schedule(month)
      expect(flash[:alert]).to include('Choose the attendance month')
    end
    expect(child.regular_schedules).to be_empty
  end

  it 'rolls back the whole upload when a student is unknown' do
    rows = "123456,false,true,true,false,false\nmissing,true,false,false,false,false\n"
    upload_schedule('2026-12', rows)

    expect(flash[:alert]).to include('Row 3: unknown student SSID')
    expect(child.regular_schedules).to be_empty
  end

  it 'rejects ambiguous weekday values instead of silently marking them true' do
    upload_schedule('2026-12', "123456,false,maybe,true,false,false\n")

    expect(flash[:alert]).to include('tuesday must explicitly be true or false')
    expect(child.regular_schedules).to be_empty
  end

  it 'rejects duplicate students and missing weekday columns' do
    upload_schedule('2026-12', "123456,false,true,true,false,false\n" * 2)
    expect(flash[:alert]).to include('duplicate student SSID')
    expect(child.regular_schedules).to be_empty

    Tempfile.create(['schedule', '.csv']) do |file|
      file.write("ssid,monday\n123456,true\n")
      file.flush
      post update_csv_path, params: {
        model: 'RegularSchedule', attendance_month: '2026-12',
        csv: Rack::Test::UploadedFile.new(file.path, 'text/csv')
      }
    end
    expect(flash[:alert]).to include('Missing schedule columns')
    expect(child.regular_schedules).to be_empty
  end

  it 'retains students omitted from a correction file, including explicit zero-day schedules' do
    other = create(:internal_child, ssid: '654321')
    create(:regular_schedule, child: other, month: Date.new(2026, 12, 1), monday: true)
    upload_schedule('2026-12', "123456,false,false,false,false,false\n")

    expect(child.regular_schedules.sole.days).to eq('')
    expect(other.regular_schedules.sole.days).to eq('月')
  end

  it 'clears omitted external students only for the selected current or future month' do
    travel_to Time.zone.local(2026, 11, 22) do
      former_student = create(:external_child, school: child.school, ssid: '654321')
      previous = create(:regular_schedule, child: former_student, month: Date.new(2026, 10, 1),
                                          monday: true)
      current = create(:regular_schedule, child: former_student, month: Date.new(2026, 11, 1),
                                         tuesday: true)
      upcoming = create(:regular_schedule, child: former_student, month: Date.new(2026, 12, 1),
                                          wednesday: true)
      later = create(:regular_schedule, child: former_student, month: Date.new(2027, 1, 1),
                                       thursday: true)

      upload_schedule('2026-11')
      expect(flash[:alert]).to be_nil
      expect(current.reload.days).to eq('')
      expect(upcoming.reload.days).to eq('水')

      upload_schedule('2026-12')
      expect(flash[:alert]).to be_nil
      expect(upcoming.reload.days).to eq('')
      expect(previous.reload.days).to eq('月')
      expect(later.reload.days).to eq('木')
      expect(former_student.regular_day?(Date.new(2026, 10, 5))).to be true
    end
  end

  it 'stops fallback for omitted external students without an upload-month record' do
    travel_to Time.zone.local(2026, 11, 22) do
      former_student = create(:external_child, school: child.school, ssid: '654321')
      previous = create(:regular_schedule, child: former_student, month: Date.new(2026, 11, 1),
                                           monday: true)
      upload_schedule('2026-12')

      expect(flash[:alert]).to be_nil
      expect(previous.reload.days).to eq('月')
      expect(former_student.regular_schedules.find_by!(month: Date.new(2026, 12, 1)).days).to eq('')
      expect(former_student.reload.regular_day?(Date.new(2027, 1, 4))).to be(false)
    end
  end

  it 'does not create omission records for students with no recent schedules' do
    travel_to Time.zone.local(2026, 11, 22) do
      unscheduled = create(:external_child, school: child.school, ssid: '654321')
      expired = create(:external_child, school: child.school, ssid: '654322')
      create(:regular_schedule, child: expired, month: Date.new(2026, 6, 1), monday: true)

      upload_schedule('2026-12')

      expect(flash[:alert]).to be_nil
      expect(unscheduled.regular_schedules).to be_empty
      expect(expired.regular_schedules.where(month: Date.new(2026, 12, 1))).to be_empty
    end
  end

  it 'preserves omitted students from other schools and non-external categories' do
    travel_to Time.zone.local(2026, 11, 22) do
      students = [
        create(:external_child, ssid: '654321', school: create(:school)),
        create(:internal_child, ssid: '654322', school: child.school),
        create(:child, category: :reservation, ssid: '654323', school: child.school),
        create(:child, category: :unknown, ssid: '654324', school: child.school)
      ]
      schedules = students.map do |student|
        create(:regular_schedule, child: student, month: Date.new(2026, 12, 1), monday: true)
      end

      upload_schedule('2026-12')

      expect(flash[:alert]).to be_nil
      expect(schedules.map { |schedule| schedule.reload.days }).to eq(['月'] * students.size)
    end
  end

  it 'preserves historical schedules for omitted students who are external now' do
    travel_to Time.zone.local(2026, 11, 22) do
      former_student = create(:internal_child, school: child.school, ssid: '654321')
      schedule = create(:regular_schedule, child: former_student, month: Date.new(2026, 9, 1),
                                          monday: true)
      original = schedule.attributes
      former_student.update!(category: :external)

      upload_schedule('2026-09')

      expect(flash[:alert]).to be_nil
      expect(schedule.reload.attributes).to eq(original)
      expect(former_student.regular_day?(Date.new(2026, 9, 7))).to be true
    end
  end

  it 'uses exported weekdays for included students even if they are external now' do
    travel_to Time.zone.local(2026, 11, 22) do
      child.update!(category: :external)

      upload_ss_schedule([ss_schedule_row(%w[火])])
      upload_schedule('2026-12')

      expect(flash[:alert]).to be_nil
      expect(child.regular_schedule_for(Date.new(2026, 9, 1)).days).to eq('火')
      expect(child.regular_schedule_for(Date.new(2026, 12, 1)).days).to eq('火, 水')
    end
  end

  it 'audits automatic clearing without creating repeat versions or clearing on failed uploads' do
    travel_to Time.zone.local(2026, 11, 22) do
      former_student = create(:external_child, school: child.school, ssid: '654321')
      schedule = create(:regular_schedule, child: former_student, month: Date.new(2026, 12, 1),
                                          monday: true)
      with_versioning do
        upload_schedule('2026-12', "123456,false,true,true,false,false\nmissing,true,false,false,false,false\n")
        expect(flash[:alert]).to be_present
        expect(schedule.reload.days).to eq('月')
        expect(schedule.versions).to be_empty

        upload_schedule('2026-12')
        upload_schedule('2026-12')

        expect(flash[:alert]).to be_nil
        expect(schedule.reload.days).to eq('')
        expect(schedule.versions.map(&:event)).to eq(['update'])
        expect(schedule.versions.sole.whodunnit).to eq(admin.id.to_s)
      end
    end
  end

  it 'records schedule edits with their admin in PaperTrail' do
    with_versioning do
      upload_schedule('2026-12')
      upload_schedule('2026-12', "123456,true,false,false,false,false\n")

      versions = child.regular_schedules.sole.versions
      expect(versions.map(&:event)).to eq(%w[create update])
      expect(versions.map(&:whodunnit).uniq).to eq([admin.id.to_s])
    end
  end

  it 'matches numeric student IDs with leading zeros but rejects malformed IDs' do
    upload_schedule('2026-12', "00123456,false,true,true,false,false\n")
    expect(flash[:alert]).to be_nil
    expect(child.regular_schedules.count).to eq(1)

    upload_schedule('2027-01', "123456oops,false,true,true,false,false\n")
    expect(flash[:alert]).to include('unknown student SSID')
    expect(child.regular_schedules.count).to eq(1)
  end

  it 'blocks raw imports that would bypass the month selector' do
    post upload_csv_path, params: { model: 'RegularSchedule' }

    expect(response).to redirect_to(csvs_path)
    expect(flash[:alert]).to include('choose an attendance month')
  end

  it 'does not let customers upload schedules' do
    sign_in create(:customer)
    upload_schedule('2026-12')

    expect(response).to redirect_to(root_path(locale: I18n.locale))
    expect(child.regular_schedules).to be_empty
  end
end
