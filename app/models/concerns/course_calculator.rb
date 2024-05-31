# frozen_string_literal: true

module CourseCalculator
  private

  # WHEN YOU CHANGE CODE HERE
  # ALSO CHANGE CODE IN THE JS PRICE CALCULATION
  # YES, I'M TALKING TO YOU FUTURE ME
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

  def member_prices
    event.member_prices.courses
  end

  def non_member_prices
    event.non_member_prices.courses
  end

  def best_price(num_regs, courses)
    return 0 if num_regs.zero?
    return spot_use(num_regs, courses) if num_regs < 3

    course = next_lowest_course(num_regs)
    cost = courses[course.to_s]
    return handle_missing_course(num_regs, courses) if cost.nil?

    @data[:course_summary] << "<p>- #{course}回コース: #{yenify(cost)}</p>"
    cost + best_price(num_regs - course, courses)
  end

  def next_lowest_course(num)
    # 50 is the largest course on the price list
    return 50 if num > 55
    # there's a 3 course (sometimes)
    return 3 if num < 5 && num >= 3

    # all other courses are multiples of 5
    (num / 5).floor(0) * 5
  end

  def handle_missing_course(num_regs, courses)
    # sometimes we don't have the 3 course, could also miss others
    if num_regs > 6
      best_price(num_regs - 5, courses) + best_price(5, courses)
    elsif num_regs > 3
      best_price(num_regs - 3, courses) + best_price(3, courses)
    else
      spot_use(num_regs, courses)
    end
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
