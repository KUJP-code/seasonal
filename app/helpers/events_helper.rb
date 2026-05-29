# frozen_string_literal: true

module EventsHelper
  SCIENCE_SUNDAY_SCHOOL_IDS = [3, 7, 9, 10, 40].freeze
  SCIENCE_START_ON = Date.new(2026, 5, 10)

  def visible_external_event_cards(child, external_event_cards)
    cards = Array(external_event_cards)
    show_science_2026?(child) ? [:science, *cards] : cards
  end

  def event_card_count(child, events, external_event_cards)
    Array(events).size + visible_external_event_cards(child, external_event_cards).size
  end

  def show_science_2026?(child)
    return false unless child

    hide_on = science_2026_hide_on(child)
    hide_on.present? && Time.zone.today >= SCIENCE_START_ON && Time.zone.today < hide_on
  end

  def science_2026_date(child)
    return nil unless child

    if SCIENCE_SUNDAY_SCHOOL_IDS.include?(child.school_id)
      Date.new(2026, 7, 5)
    else
      Date.new(2026, 7, 4)
    end
  end

  def science_2026_hide_on(child)
    event_date = science_2026_date(child)
    event_date ? event_date + 1.day : nil
  end

  def science_2026_title(child)
    base = 'Science 2026'
    school = child&.school
    school ? "#{base} (#{I18n.t("schools.#{school.name}")})" : base
  end

  def science_2026_url
    'https://my.ptsc.jp/kids-up/entry?i=Science2026'
  end

  def science_2026_image_path(child)
    case science_2026_date(child)
    when Date.new(2026, 7, 4)
      asset_path('2026-science-4th.png')
    when Date.new(2026, 7, 5)
      asset_path('2026-science-5th.png')
    else
      ''
    end
  rescue StandardError
    ''
  end
end
