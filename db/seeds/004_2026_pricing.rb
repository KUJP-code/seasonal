# Pricing rules example data for 2025/2026 testing

customer = User.find_by(email: 'customer@gmail.com')
child = customer&.children&.first

if child
  school = child.school || School.where.not(name: 'Test').first

  member_prices = PriceList.first
  non_member_prices = PriceList.second

  pricing_2025_event = school.events.create!(
    name: 'Pricing Rules 2025',
    start_date: Date.new(2025, 8, 1),
    end_date: Date.new(2025, 8, 15),
    early_bird_date: Date.new(2025, 7, 1),
    member_prices_id: member_prices.id,
    non_member_prices_id: non_member_prices.id,
    goal: 100_000
  )

  pricing_2026_event = school.events.create!(
    name: 'Pricing Rules 2026',
    start_date: Date.new(2026, 8, 1),
    end_date: Date.new(2026, 8, 15),
    early_bird_date: Date.new(2026, 7, 1),
    member_prices_id: member_prices.id,
    non_member_prices_id: non_member_prices.id,
    goal: 100_000
  )

  [pricing_2025_event, pricing_2026_event].each do |event|
    Option.create!(name: 'Photo Service', category: :event, optionable: event, cost: 1_100)
    event.time_slots.create!(
      name: "#{event.name} Slot 1",
      morning: true,
      start_time: event.start_date.to_time.change(hour: 9, min: 0),
      end_time: event.start_date.to_time.change(hour: 12, min: 0),
      close_at: event.start_date - 1.week
    )
  end

  slot = pricing_2025_event.time_slots.first
  photo_option = pricing_2025_event.options.event.first

  child.invoices.create!(
    event: pricing_2025_event,
    total_cost: 0,
    slot_regs: [slot.registrations.new(child_id: child.id)],
    opt_regs: [photo_option.registrations.new(child_id: child.id)]
  )
end

puts 'Created pricing rule example events and registrations'
