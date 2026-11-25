# frozen_string_literal: true

namespace :regular_schedules do # rubocop:disable Metrics/BlockLength
  # Uploads reprice affected bookings automatically. Use this to catch up
  # bookings priced before a month's schedule was uploaded. Unlike an upload, it
  # compares every internal student with that month's schedule, so a booking can
  # also change for other reasons (e.g. a price list edited since). Review the
  # dry run before applying.
  desc "Reprice bookings from a month's weekdays, e.g. regular_schedules:reprice[2026-12]; " \
       'dry run unless APPLY=1'
  task :reprice, [:month] => :environment do |_task, args|
    month = Date.strptime(args.fetch(:month), '%Y-%m')
    apply = ENV['APPLY'] == '1'
    child_ids = RegularSchedule.where(month:).pluck(:child_id)

    changes = Invoice.transaction do
      RegularDayRepricing.new(child_ids, month).call(apply:)
    end

    changes.each do |change|
      invoice = change.invoice
      status = invoice.in_ss ? 'confirmed' : 'unconfirmed'
      diff = change.new_total - change.old_total
      action = change.status == :review ? 'REVIEW, manual adjustments' : 'repriced'
      puts "##{invoice.id} #{invoice.child.name} (#{invoice.event.name}, #{status}, #{action}): " \
           "#{change.old_total} -> #{change.new_total} (#{format('%+d', diff)})"
    end
    result = apply ? 'listed for SMs' : 'would change. Dry run; rerun with APPLY=1 to save'
    puts "#{changes.size} bookings #{result}."
  end

  # Lists 通常レッスン afternoons booked on students' regular weekdays for SMs.
  # Uploads check the students they change; run this once to list existing ones.
  desc '通常レッスン booked on regular weekdays, listed for SMs; dry run unless APPLY=1'
  task double_bookings: :environment do
    apply = ENV['APPLY'] == '1'
    clashes = Invoice.transaction { RegularLessonDoubleBookings.new.call(apply:) }

    clashes.group_by { |clash| clash.invoice.child.school&.name }.sort_by { |_, list| -list.size }
           .each do |school, list|
      puts "#{school}: #{list.size}"
      list.each do |clash|
        dates = clash.dates.map { |date| date.strftime('%-m/%-d') }.join(', ')
        status = clash.invoice.in_ss ? '' : ' (unconfirmed)'
        puts "  ##{clash.invoice.id} #{clash.invoice.child.name}#{status}: #{dates}"
      end
    end
    result = apply ? 'listed for SMs' : 'found. Dry run; rerun with APPLY=1 to list them for SMs'
    puts "#{clashes.size} bookings #{result}."
  end
end
