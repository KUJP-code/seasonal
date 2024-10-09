Child.where.not(school_id: [nil, 1, 2]).find_each(batch_size: 100) do |child|
  event = child.school.events.first
  slots = event.time_slots.sample(rand(1..5))
  invoice = child.invoices.new(
    event_id: event.id,
    total_cost: 0,
    slot_regs: slots.map { |s| s.registrations.new(child_id: child.id) },
    opt_regs: [event.options.first.registrations.new(child_id: child.id)]

  )
  invoice.save
end

puts 'Created invoices, all done!'
