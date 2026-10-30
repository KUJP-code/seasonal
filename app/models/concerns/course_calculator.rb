# frozen_string_literal: true

module CourseCalculator
  private

  # WHEN YOU CHANGE CODE HERE
  # ALSO CHANGE CODE IN THE JS PRICE CALCULATION
  # YES, I'M TALKING TO YOU FUTURE ME
  def calc_course_cost(slots)
    @data = @data.presence || {}
    @data[:snack_cost], @data[:snack_count] = snack_cost(slots)
    @data[:extra_cost], @data[:extra_cost_count] = extra_cost(slots)
    @data[:course_summary] = +''

    @data[:course_cost] = slot_cost(slots) + @data[:extra_cost] + @data[:snack_cost]
  end

  def calc_regular_day_cost(slots)
    @data[:regular_day_prices] = slots.to_h { |s| [s.id, s.regular_day_price_for(child)] }.compact
    @data[:regular_day_count] = @data[:regular_day_prices].size
    @data[:regular_day_cost] = @data[:regular_day_prices].values.sum
  end

  def slot_cost(slots)
    calc_regular_day_cost(slots)
    package_slots = slots.reject { |slot| @data[:regular_day_prices].key?(slot.id) }
    best_price_for_event(package_slots.size, event.price_list_for(child)) + @data[:regular_day_cost]
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

  def best_price_for_event(num_regs, courses)
    return best_price(num_regs, courses) unless event.pricing_rules_2026?

    priced_slot_regs.sum do |_batch, regs|
      package_price_2026(regs.size, courses)
    end
  end

  def priced_slot_regs
    slot_regs_for_pricing =
      @data[:slot_regs].presence || slot_regs.reject(&:marked_for_destruction?)
    package_regs = slot_regs_for_pricing.reject do |reg|
      @data[:regular_day_prices].key?(reg.registerable_id)
    end
    package_regs.group_by { |reg| reg.pricing_batch || 1 }
  end

  def package_price_2026(num_regs, courses)
    remaining_regs = num_regs
    available_courses(courses).sum do |course|
      count, remaining_regs = remaining_regs.divmod(course)
      next 0 if count.zero?

      package_summary_2026(course, count, courses)
    end
  end

  def package_summary_2026(course, count, courses)
    cost = courses[course.to_s] * count
    @data[:course_summary] << "<p>- #{course}回コース x #{count}: #{yenify(cost)}</p>"
    cost
  end

  def available_courses(courses)
    courses.select { |_course, price| price.present? }
           .keys
           .map(&:to_i)
           .sort
           .reverse
  end

  def snack_cost(slots)
    charges = slots.map { |slot| slot.snack_charge_for(child) }.select(&:positive?)
    [charges.sum, charges.size]
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
