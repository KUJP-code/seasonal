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
class RegularDayRepricing
  Change = Struct.new(:invoice, :old_total, :new_total)

  def initialize(child_ids, month)
    @child_ids = Array(child_ids)
    @month = month.to_date.beginning_of_month
  end

  # Returns the bookings whose price changed. With apply: false nothing is saved.
  def call(apply: true)
    return [] if @child_ids.empty?

    affected_invoices.filter_map do |invoice|
      old_total = invoice.total_cost
      old_summary = invoice.summary
      invoice.refresh_pricing
      next if invoice.total_cost == old_total && invoice.summary == old_summary

      invoice.save! if apply
      Change.new(invoice, old_total, invoice.total_cost)
    end
  end

  private

  # Later months without their own upload fall back to this month's weekdays.
  def affected_invoices
    last_month = @month + RegularSchedule::FALLBACK_MONTHS.months
    window = @month.in_time_zone..last_month.end_of_month.in_time_zone.end_of_day
    ids = Invoice.joins(:child, :time_slots)
                 .merge(Child.internal)
                 .where(child_id: @child_ids, time_slots: { start_time: window })
                 .distinct
                 .pluck(:id)

    Invoice.where(id: ids).includes(:event, child: :regular_schedules).order(:id)
  end
end
