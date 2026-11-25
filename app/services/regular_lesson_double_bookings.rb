# frozen_string_literal: true

# Flags 通常レッスン afternoons booked on the student's regular weekday, which
# the student attends anyway. Older booking pages showed these afternoons under
# the morning activity's name, so some parents booked them by mistake.
class RegularLessonDoubleBookings
  Clash = Struct.new(:invoice, :dates)

  # child_ids: nil checks every internal student.
  def initialize(child_ids = nil)
    @child_ids = child_ids
  end

  # Returns the bookings that clash. With apply: false nothing is saved.
  def call(apply: true)
    return [] if @child_ids&.empty?

    invoices.filter_map do |invoice|
      dates = clash_dates(invoice)
      PriceChange.sync_double_booking!(invoice, dates) if apply
      Clash.new(invoice, dates) if dates.any?
    end
  end

  private

  def invoices
    scope = Invoice.real.joins(:child, :event).merge(Child.internal)
                   .where(events: { start_date: RegularDayRepricing::FIRST_EVENT_DATE.. })
    scope = scope.where(child_id: @child_ids) if @child_ids
    scope.includes(:time_slots, child: :regular_schedules).order(:id)
  end

  def clash_dates(invoice)
    invoice.time_slots
           .select { |slot| slot.regular_lesson? && invoice.child.regular_day?(slot.start_time) }
           .map { |slot| slot.start_time.to_date }.uniq.sort
  end
end
