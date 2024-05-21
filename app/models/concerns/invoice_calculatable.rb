# frozen_string_literal: true

module InvoiceCalculatable
  extend ActiveSupport::Concern
  include AdjustmentCalculator
  include CourseCalculator
  include OptionCalculator

  included do
    def generate_data
      calc_course_cost(@data[:time_slots])
      calc_option_cost(@data[:options])
      adj_cost = calc_adjustments(@data[:num_regs])

      calculated_cost = @data[:course_cost] + adj_cost + @data[:opt_cost]
      calculated_cost = 0 if calculated_cost.negative?

      @data[:total_cost] = calculated_cost
      @data
    end
  end
end
