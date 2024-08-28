# frozen_string_literal: true

module AdjustmentCalculator
  private

  def calc_adjustments(num_regs)
    first_time_adjustment if first_time?(num_regs)
    early_bird_adjustment(num_regs) if Time.zone.today < event.early_bird_date
    hat_adjustment if needs_hat?
    repeater_discount if repeater?(num_regs)
    adjustments.reduce(0) { |sum, adj| sum + adj.change }
  end

  def first_time?(num_regs)
    child.external? && child.first_seasonal && num_regs.positive?
  end

  def first_time_adjustment
    change = 1_100
    reason = '初回登録料(初めてシーズナルスクールに参加する非会員の方)'
    apply_if_never_applied(change, reason)
  end

  def applied_to_invoice?(change, reason)
    adjustments.any? { |adj| adj.change == change && adj.reason == reason }
  end

  def child_has_adjustment?(change, reason)
    child.adjustments.any? { |adj| adj.change == change && adj.reason == reason }
  end

  def early_bird_adjustment(num_regs)
    change = event.early_bird_discount
    reason = '早割'

    early_bird_count = adjustments.count { |adj| adj.reason == reason }
    while early_bird_count < num_regs
      adjustments.new(change:, reason:)
      early_bird_count += 1
    end
  end

  def needs_hat?
    return false if child.received_hat || child.internal?

    @data[:time_slots].any?(&:outdoor?)
  end

  def hat_adjustment
    change = 1_100
    reason = '帽子代(野外アクティビティに参加される方でKids UP帽子をお持ちでない方のみ)'
    apply_if_never_applied(change, reason)
  end

  def repeater?(num_regs)
    child.external? && child.first_seasonal == false && num_regs > 4
  end

  def repeater_discount
    change = -10_000
    reason = '非会員リピーター割引(以前シーズナルスクールに参加された非会員の方)'
    apply_if_not_applied_to_event(change, reason)
  end

  def apply_if_never_applied(change, reason)
    return if applied_to_invoice?(change, reason) || child_has_adjustment?(change, reason)

    adjustments.new(change:, reason:)
  end

  def apply_if_not_applied_to_event(change, reason)
    return if applied_to_invoice?(change, reason) || applied_this_event?(change, reason)

    adjustments.new(change:, reason:)
  end

  def applied_this_event?(change, reason)
    event_adjustments = child.invoices
                             .where(event_id:)
                             .where.not(id:)
                             .map(&:adjustments).flatten
    event_adjustments.any? { |a| a.change == change && a.reason == reason }
  end
end
