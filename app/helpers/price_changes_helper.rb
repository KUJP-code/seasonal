# frozen_string_literal: true

module PriceChangesHelper
  KIND_BADGES = { 'price_change' => 'text-bg-primary', 'needs_review' => 'text-bg-warning',
                  'double_booking' => 'text-bg-danger' }.freeze

  def price_change_yen(amount, signed: false)
    yen = number_to_currency(amount.abs, locale: :ja)
    return yen unless signed

    "#{amount.negative? ? '-' : '+'}#{yen}"
  end

  def price_change_kind(change)
    tag.span(t("price_changes.kinds.#{change.kind}"), class: "badge #{KIND_BADGES[change.kind]}")
  end

  def price_change_detail(change)
    if change.double_booking?
      days = t('date.abbr_day_names', locale: :ja)
      change.clash_dates.map { |date| "#{date.month}/#{date.day}(#{days[date.wday]})" }.join(', ')
    elsif change.attendance_month
      month = change.attendance_month
      t('price_changes.table.month_format', year: month.year, month: month.month)
    end
  end

  # Unseen entries for the school or area manager signed in.
  def unseen_price_change_count
    return 0 unless current_user&.school_manager? || current_user&.area_manager?

    @unseen_price_change_count ||=
      PriceChangePolicy::Scope.new(current_user, PriceChange).resolve.unseen.count
  end

  def show_price_change_alert?
    controller_name != 'price_changes' && unseen_price_change_count.positive?
  end
end
