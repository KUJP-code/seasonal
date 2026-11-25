# frozen_string_literal: true

# A booking school managers should check after a monthly weekday upload, listed
# until one of them ticks it:
# - price_change: repriced because an afternoon became or stopped being a regular day.
# - needs_review: would be repriced, but has manual adjustments (often SMs already
#   handled the regular day by hand), so it was left alone. new_total is the
#   system's price.
# - double_booking: 通常レッスン afternoons (details: ISO dates) booked on the
#   student's regular weekday, which they attend anyway. Older booking pages showed
#   these under the morning activity's name, so some were booked by mistake.
#
# A booking keeps at most one unseen entry per kind. Later uploads update it, so it
# compares the total managers last saw with the current one, and an entry whose
# reason goes away (e.g. a corrected upload) is removed.
class PriceChange < ApplicationRecord
  belongs_to :invoice
  belongs_to :seen_by, class_name: 'User', optional: true
  has_one :child, through: :invoice

  enum :kind, { price_change: 0, needs_review: 1, double_booking: 2 }

  scope :unseen, -> { where(seen_at: nil) }
  scope :seen, -> { where.not(seen_at: nil) }
  scope :for_schools, ->(school_ids) { joins(:child).where(children: { school_id: school_ids }) }

  # new_total: the booking's total now (price_change) or the system's price (needs_review).
  def self.record!(invoice, old_total:, month:, kind: :price_change, new_total: invoice.total_cost)
    change = unseen.find_or_initialize_by(invoice:, kind:)
    change.old_total = old_total if change.new_record?
    change.assign_attributes(new_total:, attendance_month: month)
    return change.save! unless change.new_total == change.old_total

    change.destroy! if change.persisted?
  end

  def self.sync_double_booking!(invoice, dates)
    current = double_booking.unseen.find_by(invoice:)
    return current&.destroy! if dates.empty?

    details = dates.map(&:iso8601).join(',')
    # Managers already ticked these exact dates.
    return current&.destroy! if double_booking.seen.exists?(invoice:, details:)
    return if current&.details == details

    (current || new(invoice:, kind: :double_booking))
      .update!(details:, old_total: invoice.total_cost, new_total: invoice.total_cost)
  end

  def difference
    new_total - old_total
  end

  def clash_dates
    details.to_s.split(',').map { Date.iso8601(_1) }
  end

  def mark_seen!(user)
    update!(seen_at: Time.current, seen_by: user)
  end
end
