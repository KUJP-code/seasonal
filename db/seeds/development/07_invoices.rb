
School.all.each do |school|
  school.children.each do |child|
    school.events.each do |event|
      child.invoices.create!([
        {
          event: event,
          total_cost: 0,
          billing_date: 1.year.from_now
        },
        {
          event: event,
          total_cost: 0,
          billing_date: 6.months.from_now,
          in_ss: true
        }
      ])
    end
  end
end

puts 'Created invoices for each child/event combo at each school'

School.all.each do |school|
  school.time_slots.each do |slot|
    school.children.each do |child|
      if slot.id.even?
        child.registrations.create!(registerable: slot, invoice: Invoice.find_by(child: child, event: slot.event))
      else
        child.registrations.create!(registerable: slot, invoice: Invoice.find_by(child: child, event: slot.event, in_ss: true))
      end
    end
  end
end

puts 'Registered children for each time slot at each event at their school'

Child.all.each do |child|
  child.time_slots.each do |slot|
    if child.id.odd?
      child.registrations.create!(registerable: slot.options.arrival.last, invoice: Invoice.find_by(child: child, event: slot.event)) unless slot.options.arrival.empty?
      child.registrations.create!(registerable: slot.options.departure.last, invoice: Invoice.find_by(child: child, event: slot.event)) unless slot.options.departure.empty?
    else
      child.registrations.create!(registerable: slot.options.regular.last, invoice: Invoice.find_by(child: child, event: slot.event)) unless slot.options.regular.empty?
      child.registrations.create!(registerable: slot.options.meal.last, invoice: Invoice.find_by(child: child, event: slot.event)) unless slot.options.meal.empty?
    end
  end

  child.events.each do |event|
    child.registrations.create!(registerable: event.options.first, invoice: Invoice.find_by(child: child, event: event))
  end
end

puts "Registered kids for an option at each event/slot they're attending"


Invoice.all.each do |invoice|
  invoice.calc_cost
end

puts 'Calculated invoice costs and added to SS now all are created'