# frozen_string_literal: true

# FIXME: This helper is for tests happening in halloween 2025 and hard codes certain cards, this entire helper can be removed once it's finished.

module ComboSlotsHelper
  def combo_card_for(event:, school:, child:, registrations:, confirmed_slot_regs:)
    return ''.html_safe unless event.name&.include?('ハロウィンパーティー 2025')

    taken_ids =
      registrations
      .select { |r| r.registerable_type == 'TimeSlot' }
      .map(&:registerable_id) +
      confirmed_slot_regs.map(&:registerable_id)

    slots_by_name = event.time_slots.index_by(&:name)

    regular_names = [
      '① 9:00-10:20 (Costume Parade)',
      '② 11:00-12:20 (Monster Party)',
      '③ 14:00-15:20 (Costume Parade)',
      '④ 16:00-17:20 (Monster Party)',
      '① 9:00-10:20 (Costume Parade) - 【19日(日)】',
      '② 11:00-12:20 (Monster Party) - 【19日(日)】'
    ]

    shin_urayasu_names = [
      '① 9:15-10:35 (Costume Parade)',
      '② 11:15-12:35 (Monster Party)',
      '③ 14:00-15:20 (Costume Parade)',
      '④ 16:00-17:20 (Monster Party)'
    ]

    mall_names = [
      '① 10:15-11:35 (Costume Parade)',
      '② 13:00-14:20 (Monster Party)',
      '③ 15:00-16:20 (Costume Parade)',
      '④ 17:00-18:20 (Monster Party)'
    ]

    names =
      case school.name
      when '新浦安' then shin_urayasu_names
      when '南町田グランベリーパーク', 'ソコラ南行徳' then mall_names
      else regular_names
      end

    map = {}
    names.each_with_index { |n, i| map[i + 1] = slots_by_name[n] }

    render_combo = lambda do |combo_name, slots, image_src|
      slots = slots.compact
      return nil if slots.empty?

      return nil if slots.any?(&:closed?)

      slot_ids = slots.map(&:id)
      return nil if slot_ids.all? { |id| taken_ids.include?(id) }

      render(
        'time_slots/combo_card',
        combo_name:,
        combo_slots: slots,
        child:,
        registrations:,
        confirmed_slot_regs:,
        event:,
        image_src:
      )
    end

    cards =
      case school.name
      when '新浦安'
        [
          render_combo.call('1+2', [map[1], map[2]], 'shinurayasu_12.jpeg'),
          render_combo.call('3+4', [map[3], map[4]], 'main_34.jpeg')
        ]
      when '南町田グランベリーパーク', 'ソコラ南行徳'
        [
          render_combo.call('2+3', [map[2], map[3]], 'mall_23.jpeg'),
          render_combo.call('3+4', [map[3], map[4]], 'mall_34.jpeg')
        ]
      when '大倉山'
        [
          render_combo.call('1+2', [map[1], map[2]], 'main_12.jpeg'),
          render_combo.call('3+4', [map[3], map[4]], 'main_34.jpeg'),
          render_combo.call('5+6', [map[5], map[6]], 'main_12.jpeg')
        ]
      else
        [
          render_combo.call('1+2', [map[1], map[2]], 'main_12.jpeg'),
          render_combo.call('3+4', [map[3], map[4]], 'main_34.jpeg')
        ]
      end

    safe_join(cards.compact)
  end
end
