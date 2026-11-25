# frozen_string_literal: true

# Reprices Seasonal School bookings after children's monthly weekdays change,
# including confirmed bookings, so saved totals match the uploaded schedules.
#
# A booking is priced afternoon by afternoon from each afternoon's own month,
# so a January upload changes January afternoons while December afternoons in
# the same booking keep using the December schedule.
#
# Only currently internal students are repriced. Eligibility for the regular-day
# rate uses today's membership, so repricing a student who has since withdrawn
# would also remove discounts from months they attended. Those stay with the SMs.
#
# Only events starting on or after FIRST_EVENT_DATE (Winter School 2026, the
# first priced from monthly weekdays) are touched, so uploading an old month can
# never rewrite older bookings.
#
# Bookings with manual adjustments (any but the automatic early-bird, first-time,
# hat and repeater ones) are never repriced: SMs often adjusted regular days by
# hand, which repricing would apply twice. They are listed for review.
class RegularDayRepricing
  FIRST_EVENT_DATE = Date.new(2026, 12, 1)

  # status: :repriced, or :review for bookings with manual adjustments.
  Change = Struct.new(:invoice, :old_total, :new_total, :status)

  # previous: { child_id => the month's schedule before the upload (an unsaved
  # copy), or nil when there was none }. With it, only bookings where an afternoon
  # becomes or stops being a regular day are repriced, so prices that drifted for
  # other reasons (e.g. pricing rules changed since booking) are left alone.
  # Without it (the catch-up task), every booking is compared with current prices.
  def initialize(child_ids, month, previous: nil)
    @child_ids = Array(child_ids)
    @month = month.to_date.beginning_of_month
    @previous = previous
  end

  # Returns the bookings whose price changed. With apply: false nothing is saved.
  def call(apply: true)
    return [] if @child_ids.empty?

    affected_invoices.filter_map { |invoice| reprice(invoice, apply) }
  end

  private

  def reprice(invoice, apply)
    return unless regular_days_changed?(invoice)

    old_total = invoice.total_cost
    old_summary = invoice.summary
    invoice.refresh_pricing
    return if invoice.total_cost == old_total && invoice.summary == old_summary
    return review(invoice, old_total, apply) if invoice.adjustments.any?(&:manual?)

    save(invoice, old_total) if apply
    Change.new(invoice, old_total, invoice.total_cost, :repriced)
  end

  def regular_days_changed?(invoice)
    return true if @previous.nil?

    child = invoice.child
    before = schedules_before_upload(child)
    invoice.time_slots.any? do |slot|
      date = slot.start_time
      slot.regular_day_rate_for(child) &&
        child.regular_day?(date) != child.regular_day?(date, schedules: before)
    end
  end

  def schedules_before_upload(child)
    others = child.regular_schedules.reject { |schedule| schedule.month == @month }
    others + [@previous[child.id]].compact
  end

  # The booking keeps its price; managers compare it with the system's.
  def review(invoice, old_total, apply)
    return if invoice.total_cost == old_total

    if apply
      PriceChange.record!(invoice, kind: :needs_review, old_total:, month: @month,
                                   new_total: invoice.total_cost)
    end
    Change.new(invoice, old_total, invoice.total_cost, :review)
  end

  # Confirmed bookings skip PaperTrail, so force a version: the booking's history
  # then shows the price before this upload.
  def save(invoice, old_total)
    invoice.paper_trail.save_with_version(in_after_callback: true)
    raise ActiveRecord::RecordInvalid, invoice if invoice.errors.any?

    PriceChange.record!(invoice, old_total:, month: @month) unless invoice.total_cost == old_total
  end

  # Later months without their own upload fall back to this month's weekdays.
  def affected_invoices
    last_month = @month + RegularSchedule::FALLBACK_MONTHS.months
    window = @month.in_time_zone..last_month.end_of_month.in_time_zone.end_of_day
    ids = Invoice.joins(:child, :event, :time_slots)
                 .merge(Child.internal)
                 .where(child_id: @child_ids, time_slots: { start_time: window })
                 .where(events: { start_date: FIRST_EVENT_DATE.. })
                 .distinct
                 .pluck(:id)

    Invoice.where(id: ids).includes(:event, :adjustments, time_slots: :event,
                                                          child: :regular_schedules).order(:id)
  end
end
