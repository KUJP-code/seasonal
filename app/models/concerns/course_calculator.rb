# frozen_string_literal: true

module CourseCalculator
  private

  def calc_course_cost(slots)
    @data[:snack_cost], @data[:snack_count] = snack_cost(slots)
    @data[:extra_cost], @data[:extra_cost_count] = extra_cost(slots)

    @data[:course_cost] =
      slot_cost(@data[:num_regs]) + @data[:extra_cost] + @data[:snack_cost]
  end

  def slot_cost(num_regs)
    if child.member?
      best_price(num_regs, member_prices)
    else
      best_price(num_regs, non_member_prices)
    end
  end

  def best_price(num_regs, courses)
    return 0 if num_regs.zero?

    if [3, 4].include?(num_regs)
      cost = courses['3']

      @breakdown << "<p>- 3回コース: #{yenify(cost)}</p>" unless @breakdown.nil?
      return cost + best_price(num_regs - 3, courses)
    end

    if num_regs >= 55
      @breakdown << "<p>- 50回コース: #{yenify(courses['50'])}</p>" unless @breakdown.nil?
      return courses['50'] + best_price(num_regs - 50, courses)
    end

    course = nearest_five(num_regs)
    cost = courses[course.to_s]

    @breakdown << "<p>- #{course}回コース: #{yenify(cost)}</p>" unless cost.nil? || @breakdown.nil?
    return cost + best_price(num_regs - course, courses) unless num_regs < 5

    spot_use(num_regs, courses)
  end

  def snack_cost(slots)
    snack_count = slots.count(&:snack)
    snack_cost = snack_count * 165

    [snack_cost, snack_count]
  end

  def extra_cost(slots)
    extra_cost_count = 0
    extra_cost = slots.reduce(0) do |sum, slot|
      slot_extra_cost = slot.extra_cost_for(child)
      extra_cost_count += 1 if slot_extra_cost.positive?
      sum + slot_extra_cost
    end

    [extra_cost, extra_cost_count]
  end
end
