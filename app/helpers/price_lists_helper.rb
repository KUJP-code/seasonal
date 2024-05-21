# frozen_string_literal: true

module PriceListsHelper
  def course_cost(price_list, course_number)
    return '' if price_list.courses.nil?

    price_list.courses[course_number] || ''
  end
end
