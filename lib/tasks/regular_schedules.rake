# frozen_string_literal: true

namespace :regular_schedules do
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
      puts "##{invoice.id} #{invoice.child.name} (#{invoice.event.name}, #{status}): " \
           "#{change.old_total} -> #{change.new_total} (#{format('%+d', diff)})"
    end
    result = apply ? 'repriced' : 'would change. Dry run; rerun with APPLY=1 to save'
    puts "#{changes.size} bookings #{result}."
  end
end
