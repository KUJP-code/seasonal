# frozen_string_literal: true

module EventsHelper
  MEGA_GAME_MAY_23_SCHOOL_IDS = [
    4, 5, 6, 8, 11, 13, 14, 15, 17, 18, 20, 22, 23, 25, 27, 28, 32, 33, 34,
    36, 39, 41
  ].freeze
  MEGA_GAME_MAY_24_SCHOOL_IDS = [
    3, 7, 9, 10, 12, 16, 19, 21, 24, 26, 29, 30, 31, 35, 40
  ].freeze

  def event_card_child
    current_user&.children&.first
  end

  def event_card_school(child = event_card_child)
    child&.school
  end

  def show_mega_game?(child = event_card_child)
    return false unless child

    hide_on = mega_game_hide_on(child)
    hide_on.present? && Time.zone.today < hide_on
  end

  def mega_game_date(child = event_card_child)
    return nil unless child

    case child.school_id
    when *MEGA_GAME_MAY_23_SCHOOL_IDS
      Date.new(2026, 5, 23)
    when *MEGA_GAME_MAY_24_SCHOOL_IDS
      Date.new(2026, 5, 24)
    end
  end

  def mega_game_hide_on(child = event_card_child)
    event_date = mega_game_date(child)
    event_date ? event_date + 1.day : nil
  end

  def mega_game_title(child = event_card_child)
    base = 'Mega Game 2026'
    school = event_card_school(child)
    school ? "#{base} (#{I18n.t("schools.#{school.name}")})" : base
  end

  def mega_game_url
    'https://my.ptsc.jp/kids-up/entry?i=Mega2026'
  end

  def mega_game_image_path(child = event_card_child)
    case mega_game_date(child)
    when Date.new(2026, 5, 23)
      asset_path('mega_game_23.webp')
    when Date.new(2026, 5, 24)
      asset_path('mega_game_24.webp')
    else
      ''
    end
  rescue StandardError
    ''
  end

  def mega_game_avif_path(_child = event_card_child)
    ''
  rescue StandardError
    ''
  end
end
