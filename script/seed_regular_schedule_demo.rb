# frozen_string_literal: true

# Run explicitly with:
# env -u DATABASE_URL PGHOST=/tmp PGPORT=5432 RAILS_ENV=development bundle exec rails runner script/seed_regular_schedule_demo.rb
config = ActiveRecord::Base.connection_db_config
unless Rails.env.development? && config.database == 'db_prototype_v2_development' &&
       [nil, '/tmp', 'localhost', '127.0.0.1'].include?(config.configuration_hash[:host])
  abort 'This demo is restricted to the local development database.'
end
unless ActiveRecord::Base.connection.select_value('SELECT current_database()') == config.database
  abort 'The connected database does not match the development database.'
end

ActiveRecord::Base.transaction do
  parent = User.find_or_initialize_by(email: 'customer@example.com')
  if parent.new_record?
    parent.assign_attributes(
      password: 'customerpassword', role: :customer, name: '表示確認 保護者',
      katakana_name: 'ヒョウジカクニン ホゴシャ', phone: '090-0000-0000',
      address: '開発環境テスト住所', postcode: '000-0000', prefecture: '東京都'
    )
    parent.skip_confirmation!
    parent.save!
  end
  abort 'The demo account must be a customer.' unless parent.customer?

  school = School.where.not(id: [1, 2]).first || School.first!
  child = parent.children.find_or_initialize_by(en_name: 'Regular Schedule Demo')
  child.assign_attributes(
    name: '通学日 テスト', katakana_name: 'ツウガクビ テスト', ssid: 9_900_000_001, school:,
    birthday: Date.new(2018, 4, 1), category: :internal,
    allergies: 'なし', photos: 'OK', first_seasonal: false, received_hat: true
  )
  child.save!
  schedule = child.regular_schedules.find_or_initialize_by(month: Date.new(2026, 12, 1))
  schedule.update!(monday: false, tuesday: true, wednesday: true, thursday: false, friday: false)

  prices = PriceList.find_by(name: '通学曜日表示テスト料金')
  unless prices
    courses = [1, 3, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50]
    attributes = courses.to_h { |size| ["course#{size}", ''] }
    prices = PriceList.create!(attributes.merge(name: '通学曜日表示テスト料金',
                                               course1: '5500', course5: '22000'))
  end

  event = school.events.find_or_initialize_by(name: '通学曜日表示テスト 2026')
  event.update!(start_date: Date.new(2026, 12, 15), end_date: Date.new(2026, 12, 24),
                early_bird_date: Date.new(2026, 11, 1), early_bird_discount: 0,
                member_prices: prices, non_member_prices: prices, released: true, goal: 100_000)
  event.description = '開発環境専用：火・水が通学日です。午後の通学日だけ赤い表示が付きます。'
  event.save!
  event.options.find_or_create_by!(name: 'フォトサービス', category: :event) { |opt| opt.cost = 1100 }

  activities = [[15, '雪だるまアイス'], [16, '雪の結晶オーナメント'],
                [17, 'ウィンタースポーツ大会'], [18, '氷のゲーム対決']]
  mornings = activities.map do |day, name|
    slot = event.time_slots.find_or_initialize_by(name:, morning: true)
    slot.update!(start_time: Time.zone.local(2026, 12, day, 10),
                 end_time: Time.zone.local(2026, 12, day, 13),
                 close_at: Time.zone.local(2026, 12, day - 1, 18), category: :seasonal)
    slot
  end

  invoice = child.invoices.find_or_initialize_by(event:)
  selected_slots = [mornings[0], mornings[0].afternoon_slot, mornings[2].afternoon_slot]
  selected_slots.each do |slot|
    next if invoice.slot_regs.any? { |reg| reg.registerable_id == slot.id }

    invoice.slot_regs.build(child:, registerable: slot)
  end
  invoice.save!

  puts({ environment: Rails.env, database: config.database, customer: parent.email,
         student: child.name, weekdays: schedule.days, booking_id: invoice.id,
         student_path: "/ja/children/#{child.id}", booking_path: "/ja/invoices/#{invoice.id}",
         new_booking_path: "/ja/invoices/new?event_id=#{event.id}&child=#{child.id}" }.to_json)

  second_child = parent.children.find_or_initialize_by(en_name: 'Afternoon Schedule Demo')
  second_child.update!(
    name: '午後のみ テスト', katakana_name: 'ゴゴノミ テスト', ssid: 9_900_000_002, school:,
    birthday: Date.new(2017, 6, 1), category: :internal,
    allergies: 'なし', photos: 'OK', first_seasonal: false, received_hat: true
  )
  second_schedule = second_child.regular_schedules.find_or_initialize_by(month: Date.new(2026, 12, 1))
  second_schedule.update!(monday: true, tuesday: false, wednesday: false, thursday: true, friday: true)

  afternoon_events = [
    { name: '午後のみ・冬の工作体験 2026',
      days: [15, 16, 17, 18, 21],
      activities: %w[雪だるまアイス 雪の結晶オーナメント ウィンタースポーツ大会 氷のゲーム対決 冬のキャンドル作り],
      children: [child] },
    { name: '午後のみ・クリスマス体験 2026',
      days: [21, 22, 23, 24, 25],
      activities: %w[クリスマスカード作り スノードーム作り クリスマスクッキー クリスマスゲーム大会 クリスマスパーティー],
      children: [child, second_child] }
  ]

  afternoon_events.each do |demo|
    afternoon_event = school.events.find_or_initialize_by(name: demo[:name])
    afternoon_event.update!(
      start_date: Date.new(2026, 12, demo[:days].first),
      end_date: Date.new(2026, 12, demo[:days].last),
      early_bird_date: Date.new(2026, 11, 1), early_bird_discount: 0,
      member_prices: prices, non_member_prices: prices, released: true, goal: 100_000
    )
    afternoon_event.description = '開発環境専用：午前のない午後アクティビティの表示確認用です。'
    afternoon_event.save!
    afternoon_event.options.find_or_create_by!(name: 'フォトサービス', category: :event) do |opt|
      opt.cost = 1100
    end

    afternoons = demo[:days].zip(demo[:activities]).map do |day, name|
      slot = afternoon_event.time_slots.find_or_initialize_by(name:, morning: false)
      slot.update!(start_time: Time.zone.local(2026, 12, day, 13, 30),
                   end_time: Time.zone.local(2026, 12, day, 18, 30),
                   close_at: Time.zone.local(2026, 12, day - 1, 18), category: :seasonal)
      slot
    end

    demo[:children].each do |student|
      booking = student.invoices.find_or_initialize_by(event: afternoon_event)
      # Keep the last activity available for trying a new booking or adding a day.
      afternoons.first(4).each do |slot|
        next if booking.slot_regs.any? { |reg| reg.registerable_id == slot.id }

        booking.slot_regs.build(child: student, registerable: slot)
      end
      booking.save!

      puts({ student: student.name, weekdays: student.regular_schedule_for(Date.new(2026, 12, 1)).days,
             event: afternoon_event.name, afternoon_only: true,
             booking_path: "/ja/invoices/#{booking.id}",
             student_path: "/ja/children/#{student.id}",
             new_booking_path: "/ja/invoices/new?event_id=#{afternoon_event.id}&child=#{student.id}" }.to_json)
    end
  end

  january_schedule = child.regular_schedules.find_or_initialize_by(month: Date.new(2027, 1, 1))
  january_schedule.update!(monday: false, tuesday: false, wednesday: true, thursday: true, friday: false)
  winter = school.events.find_or_initialize_by(name: '月別通学曜日・冬休みテスト 2026–2027')
  winter.update!(start_date: Date.new(2026, 12, 15), end_date: Date.new(2027, 1, 8),
                 early_bird_date: Date.new(2026, 11, 1), early_bird_discount: 0,
                 member_prices: prices, non_member_prices: prices, released: true, goal: 100_000)
  winter.description = '開発環境専用：12月は火・水、1月は水・木。確定済みのお申込でも月別の通学日を表示します。'
  winter.save!
  winter.options.find_or_create_by!(name: 'フォトサービス', category: :event) { |opt| opt.cost = 1100 }

  winter_slots = [[2026, 12, 15, '12月のアイス作り'], [2026, 12, 17, '12月のスポーツ大会'],
                  [2027, 1, 5, '1月のアイス作り'], [2027, 1, 6, '1月の工作'],
                  [2027, 1, 7, '1月のスポーツ大会']].map do |year, month, day, name|
    slot = winter.time_slots.find_or_initialize_by(name:, morning: false)
    slot.update!(start_time: Time.zone.local(year, month, day, 13, 30),
                 end_time: Time.zone.local(year, month, day, 18, 30),
                 close_at: Time.zone.local(year, month, day - 1, 18), category: :seasonal)
    slot
  end
  winter_booking = child.invoices.find_or_initialize_by(event: winter)
  winter_slots.each do |slot|
    next if winter_booking.slot_regs.any? { |reg| reg.registerable_id == slot.id }

    winter_booking.slot_regs.build(child:, registerable: slot)
  end
  if winter_booking.new_record?
    winter_booking.created_at = Time.zone.local(2026, 10, 10)
    winter_booking.save!
    winter_booking.update!(in_ss: true)
  else
    winter_booking.save!
  end
  puts({ event: winter.name, confirmed_booking: winter_booking.in_ss?,
         booking_path: "/ja/invoices/#{winter_booking.id}",
         new_booking_path: "/ja/invoices/new?event_id=#{winter.id}&child=#{child.id}" }.to_json)
end
