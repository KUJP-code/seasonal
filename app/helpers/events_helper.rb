# frozen_string_literal: true

module EventsHelper
  # Schools that use the 21st and special image
  EXTERNAL_EVENT_SPECIAL_SCHOOL_IDS = [7, 9, 10, 3].freeze

  def show_christmas_event?(child = external_event_child)
    return false unless child

    Time.zone.today <= external_event_date(child)
  end

  def external_event_child
    current_user&.children&.first
  end

  def external_event_school(child = external_event_child)
    child&.school
  end

  def external_event_school_id(child = external_event_child)
    child&.school_id
  end

  def external_event_is_special?(child = external_event_child)
    EXTERNAL_EVENT_SPECIAL_SCHOOL_IDS.include?(external_event_school_id(child))
  end

  # Dec 21 for special IDs; Dec 20 otherwise. No date if no child.
  def external_event_date(child = external_event_child)
    return nil unless child

    year = 2025
    day  = external_event_is_special?(child) ? 21 : 20
    Date.new(year, 12, day)
  end

  # Title: always "クリスマス2025", optionally append school in parentheses.
  def external_event_title(child = external_event_child)
    base = 'クリスマス2025'
    school = external_event_school(child)
    school ? "#{base} (#{I18n.t("schools.#{school.name}")})" : base
  end

  # URL
  def external_event_url
    'https://kids-up.jp/events/christmas-2025/form/'
  end

  def external_event_image_path(child = external_event_child)
    if external_event_is_special?(child)
      asset_path('christmas_special.png')
    else
      asset_path('christmas_default.png')
    end
  rescue StandardError
    ''
  end

  def external_event_avif_path(child = external_event_child)
    if external_event_is_special?(child)
      asset_path('christmas_special.avif')
    else
      asset_path('christmas_default.avif')
    end
  rescue StandardError
    ''
  end

end
