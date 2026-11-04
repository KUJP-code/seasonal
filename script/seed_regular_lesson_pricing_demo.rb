# frozen_string_literal: true

# env -u DATABASE_URL PGHOST=/tmp PGPORT=5432 RAILS_ENV=development bundle exec rails runner script/seed_regular_lesson_pricing_demo.rb
config = ActiveRecord::Base.connection_db_config
unless Rails.env.development? && config.database == 'db_prototype_v2_development' &&
       [nil, '/tmp', 'localhost', '127.0.0.1'].include?(config.configuration_hash[:host])
  abort 'This demo is restricted to the local development database.'
end

ActiveJob::Base.queue_adapter = :test
ActionMailer::Base.perform_deliveries = false

ApplicationRecord.transaction do
  parent = User.find_by!(email: 'customer@example.com')
  child = parent.children.internal.find_by!(en_name: 'Regular Schedule Demo')
  raise 'Expected Tuesday attendance and Thursday non-attendance' unless
    child.regular_day?(Date.new(2026, 12, 15)) && !child.regular_day?(Date.new(2026, 12, 17))

  prices = PriceList.find_or_initialize_by(name: '通常レッスン午後・料金比較テスト')
  prices.assign_attributes(PriceList::COURSE_SIZES.to_h { |size| ["course#{size}", ''] })
  prices.update!(course1: '5500', course5: '22000', course10: '38000',
                 regular_day_afternoon_price: 2700)

  event = child.school.events.find_or_initialize_by(name: '午後通常レッスン・料金確認 2026')
  event.update!(start_date: Date.new(2026, 12, 15), end_date: Date.new(2026, 12, 24),
                early_bird_date: Date.new(2026, 11, 1), early_bird_discount: 0,
                member_prices: prices, non_member_prices: prices, released: true, goal: 100_000)
  event.description = '開発用：火・水が通学日。12/15(火)と12/17(木)は通常レッスンの午後。12/22(火)と12/24(木)は午後アクティビティ。'
  event.save!

  lessons = [[15, '12/15 午前アクティビティ'], [17, '12/17 午前アクティビティ']].map do |day, name|
    morning = event.time_slots.find_or_initialize_by(name:, morning: true)
    morning.update!(start_time: Time.zone.local(2026, 12, day, 10),
                    end_time: Time.zone.local(2026, 12, day, 13),
                    close_at: Time.zone.local(2026, 12, day - 1, 18), category: :seasonal,
                    snack: false, closed: false)
    afternoon = morning.afternoon_slot
    afternoon.update!(start_time: Time.zone.local(2026, 12, day, 13, 30),
                      end_time: Time.zone.local(2026, 12, day, 18, 30),
                      snack: true, closed: false)
    raise 'Regular lessons must not use the special offer' unless afternoon.regular_day_price_for(child).nil?
    afternoon
  end

  [[22, '通学日・午後アクティビティ'], [24, '通学日以外・午後アクティビティ']].each do |day, name|
    slot = event.time_slots.find_or_initialize_by(name:, morning: false, morning_slot_id: nil)
    slot.update!(start_time: Time.zone.local(2026, 12, day, 13, 30),
                 end_time: Time.zone.local(2026, 12, day, 18, 30),
                 close_at: Time.zone.local(2026, 12, day - 1, 18),
                 category: :seasonal, snack: true, closed: false)
    expected = day == 22 ? 2700 : nil
    raise 'Activity offer does not match the demo schedule' unless slot.regular_day_price_for(child) == expected
  end

  invoice = child.invoices.find_or_initialize_by(event:)
  lessons.each do |slot|
    next if invoice.slot_regs.any? { |reg| reg.registerable_id == slot.id }

    invoice.slot_regs.build(child:, registerable: slot)
  end
  invoice.calc_cost
  invoice.save!
  raise 'Unexpected demo price' unless invoice.total_cost == 11_450

  puts({ customer: parent.email, child: child.name, child_id: child.id,
         weekdays: child.regular_schedule_for(Date.new(2026, 12, 1)).days,
         event_id: event.id, invoice_id: invoice.id, total_cost: invoice.total_cost,
         booking_path: "/ja/invoices/new?event_id=#{event.id}&child=#{child.id}",
         invoice_path: "/ja/invoices/#{invoice.id}" }.to_json)
end
