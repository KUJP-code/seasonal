# frozen_string_literal: true

module InvoicesHelper
  def invoice_version_actor(version)
    actor = version.whodunnit.to_s
    return t('invoices.show.system_change') unless actor.match?(/\A[1-9]\d*\z/)

    User.find_by(id: actor)&.name || t('invoices.show.deleted_user')
  end

  def booking_summary(invoice)
    summary = sanitize(invoice.summary, tags: %w[h2 h3 h4 h5 div p], attributes: %w[class id])
    return summary unless current_user&.staff?

    regular_dates = regular_afternoon_dates(invoice)
    return summary if regular_dates.empty?

    annotate_regular_days(summary, regular_dates)
  end

  private

  def regular_afternoon_dates(invoice)
    invoice.validated_slots.filter_map do |slot|
      next if slot.morning? || !invoice.child.regular_day?(slot.start_time)

      slot.name_date.delete_prefix(slot.name).squish
    end
  end

  def annotate_regular_days(summary, regular_dates)
    # Summaries also power emails and retain the original financial details.
    # Decorate their activity headings only for the web, including older bookings.
    fragment = Nokogiri::HTML.fragment(summary)
    fragment.css('.slot_regs h5').each do |heading|
      # Match the dated afternoon suffix, which survives an activity-name correction.
      next unless heading.text.squish.end_with?(*regular_dates)

      label = tag.span(t('regular_schedules.regular_day'), class: 'regular-day text-danger ms-2')
      heading.add_child(" #{label}")
    end

    sanitize(fragment.to_html, tags: %w[h2 h3 h4 h5 div p span], attributes: %w[class id])
  end
end
