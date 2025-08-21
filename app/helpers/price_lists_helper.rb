# frozen_string_literal: true

module PriceListsHelper
  def course_cost(price_list, course_number)
    return '' if price_list.courses.nil?

    price_list.courses[course_number] || ''
  end


  # returns -500 if this invoice (party) qualifies for early-bird, else 0.
  def early_bird_adjustment_for(invoice, event:, child:)
    regs = invoice.slot_regs.reject(&:marked_for_destruction?)
    return 0 if regs.empty?

    slots_by_id = event.time_slots.index_by(&:id)

    applies = regs.any? do |r|
      slot = slots_by_id[r.registerable_id]
      next false unless slot
      (activity_modifier(slot, child) || 0) < 0
    end

    applies ? -500 : 0
  end
end