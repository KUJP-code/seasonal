# frozen_string_literal: true

module InvoicesHelper
  def photo_service_copy_scope(event)
    winter_event = event.name == 'ウインタースクール 2026' && event.start_date&.year == 2026
    before_cutoff = Time.current.in_time_zone('Tokyo').to_date <= Date.new(2027, 1, 7)

    winter_event && before_cutoff ? 'photo_service.winter_2026' : 'photo_service'
  end

  def invoice_version_actor(version)
    actor = version.whodunnit.to_s
    return t('invoices.show.system_change') unless actor.match?(/\A[1-9]\d*\z/)

    User.find_by(id: actor)&.name || t('invoices.show.deleted_user')
  end

  def booking_summary(invoice)
    summary = sanitize(invoice.summary, tags: %w[h2 h3 h4 h5 div p], attributes: %w[class id])
    summary = label_regular_lessons(summary, invoice)
    # Regular days follow today's schedule, so they would mislabel history versions,
    # which can also point at a merged duplicate child that was since deleted.
    return summary unless current_user&.staff? && invoice.paper_trail.live?
    return summary unless invoice.child&.internal?

    regular_dates = regular_afternoon_dates(invoice)
    return summary if regular_dates.empty?

    annotate_regular_days(summary, regular_dates)
  end

  private

  def label_regular_lessons(summary, invoice)
    lesson_dates, activity_headings = regular_lesson_headings(invoice)
    return summary if lesson_dates.empty?

    fragment = Nokogiri::HTML.fragment(summary)
    fragment.css('.slot_regs h5').each do |heading|
      next if activity_headings.include?(heading.text.squish)

      date = lesson_dates.find { |suffix| heading.text.squish.end_with?(suffix) }
      heading.content = "通常レッスン #{date}" if date
    end

    sanitize(fragment.to_html, tags: %w[h2 h3 h4 h5 div p], attributes: %w[class id])
  end

  def regular_lesson_headings(invoice)
    lessons, activities = invoice.validated_slots.partition(&:regular_lesson?)
    lesson_dates = lessons.map { |slot| slot.name_date.delete_prefix(slot.booking_name).squish }
    [lesson_dates, activities.map { |slot| slot.name_date.squish }]
  end

  def regular_afternoon_dates(invoice)
    invoice.validated_slots.filter_map do |slot|
      next if slot.morning? || slot.regular_lesson? || !invoice.child.regular_day?(slot.start_time)

      slot.name_date.delete_prefix(slot.booking_name).squish
    end
  end

  def annotate_regular_days(summary, regular_dates)
    # Summaries also power emails and retain the original financial details.
    # Decorate their activity headings only for the web, including older bookings.
    fragment = Nokogiri::HTML.fragment(summary)
    fragment.css('.slot_regs h5').each do |heading|
      next unless heading.text.squish.end_with?('(午後)')
      next if heading.text.squish.start_with?('通常レッスン (')

      # Match the dated afternoon suffix, which survives an activity-name correction.
      next unless heading.text.squish.end_with?(*regular_dates)

      label = tag.span(t('regular_schedules.regular_day'), class: 'regular-day text-danger ms-2')
      heading.add_child(" #{label}")
    end

    sanitize(fragment.to_html, tags: %w[h2 h3 h4 h5 div p span], attributes: %w[class id])
  end
end
