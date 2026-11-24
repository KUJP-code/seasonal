# frozen_string_literal: true

module ChildrenHelper
  # Staff-only weekday summary.
  # - dates: a booking's activity dates (or an event's range). Each calendar month
  #   uses its own effective schedule; differing months are labelled, e.g.
  #   "12月 月・水 ｜ 1月 火・木". Identical months collapse to one unlabelled set.
  # - events: the latest event's final month, as on combined booking lists.
  # - neither: the latest uploaded schedule, as on student information.
  def monthly_regular_days(child, events: nil, dates: nil)
    return '' unless child.internal?

    dates = Array(dates).compact
    if dates.empty?
      return format_regular_days(latest_regular_schedule(child)) if events.nil?

      dates = Array(Array(events).filter_map(&:end_date).max)
    end

    regular_days_by_month(child, dates)
  end

  def arrival_time_for(slot, arrive_opt)
    f_time(slot.start_time + arrive_opt.modifier.minutes).concat('~')
  end

  def child_categories
    forbidden = %w[default unknown]
    Child.categories.keys.reject { |k| forbidden.include?(k) }
         .map { |k| [t(".#{k}"), k] }
  end

  def child_photos
    forbidden = %w[マイページOK Unknown]
    Child.photos.keys.reject { |k| forbidden.include?(k) }
  end

  def child_primary_grades
    Child.grades.keys[2..11].map { |k| [k, k] }
  end

  def departure_time_for(slot, depart_opt)
    f_time(slot.end_time + depart_opt.modifier.minutes).concat('~')
  end

  def family_name(child)
    return '' if child.name.nil?

    split_name(child.name).first
  end

  def first_name(child)
    return '' if child.name.nil?

    split_name(child.name).last
  end

  def kana_family(child)
    return '' if child.katakana_name.nil?

    split_name(child.katakana_name).first
  end

  def kana_first(child)
    return '' if child.katakana_name.nil?

    split_name(child.katakana_name).last
  end

  def kanji_category(category)
    case category
    when 'internal'
      '通学生'
    when 'reservation'
      '予約生'
    else
      '非会員'
    end
  end

  def parent_link(parent)
    return 'なし' if parent.nil?

    link_to parent.name, user_path(parent)
  end

  private

  def latest_regular_schedule(child)
    child.regular_schedules.select(&:month).max_by(&:month)
  end

  def regular_days_by_month(child, dates)
    by_month = activity_months(dates).index_with do |month|
      format_regular_days(child.regular_schedule_for(month))
    end.compact_blank
    return by_month.values.first.to_s if by_month.values.uniq.size <= 1

    by_month.map { |month, days| "#{month.month}月 #{days}" }.join(' ｜ ')
  end

  def activity_months(dates)
    dates.map { |date| date.to_date.beginning_of_month }.uniq.sort
  end

  def format_regular_days(schedule)
    return '' unless schedule

    schedule.days.gsub(', ', '・').presence || '—'
  end

  def split_name(name)
    parts = name.to_s.strip.split(/[[:space:]　]+/, 2)
    [parts.first.to_s, parts.second.to_s]
  end
end
