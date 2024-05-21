# frozen_string_literal: true

module CourseCalculator
  private

  def calc_course_cost(slots)
    @data[:snack_cost], @data[:snack_count] = snack_cost(slots)
    @data[:extra_cost], @data[:extra_cost_count] = extra_cost(slots)
    @data[:course_summary] = +''

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

      @data[:course_summary] << "<p>- 3回コース: #{yenify(cost)}</p>"
      return cost + best_price(num_regs - 3, courses)
    end

    if num_regs >= 55
      @data[:course_summary] << "<p>- 50回コース: #{yenify(courses['50'])}</p>"
      return courses['50'] + best_price(num_regs - 50, courses)
    end

    course = nearest_five(num_regs)
    cost = courses[course.to_s]

    @data[:course_summary] << "<p>- #{course}回コース: #{yenify(cost)}</p>" unless cost.nil?
    return cost + best_price(num_regs - course, courses) unless num_regs < 5

    spot_use(num_regs, courses)
  end

  def member_prices
    event.member_prices.courses
  end

  def non_member_prices
    event.non_member_prices.courses
  end

  # Finds the nearest multiple of 5 to the passed integer
  # Because courses are in multiples of 5, other than spot use
  def nearest_five(num)
    (num / 5).floor(0) * 5
  end

  def spot_use(num_regs, courses)
    spot_cost = num_regs * courses['1']
    unless spot_cost.zero? || @data[:course_summary].nil?
      @data[:course_summary] << "<p>- 1回コース x #{num_regs}: #{yenify(spot_cost)}</p>\n"
    end
    spot_cost
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
