# frozen_string_literal: true

module InvoiceCalculatable
  extend ActiveSupport::Concern
  include AdjustmentCalculator
  include CourseCalculator
  include OptionCalculator

  included do
    def generate_data(ignore_slots, ignore_opts)
      @data = { options: validated_options(ignore_opts),
                time_slots: validated_slots(ignore_slots) }
      @data[:num_regs] = @data[:time_slots].size
      calc_course_cost(@data[:time_slots])
      calc_option_cost(@data[:options])
      adj_cost = calc_adjustments(@data[:num_regs])

      calculated_cost = @data[:course_cost] + adj_cost + @data[:opt_cost]
      calculated_cost = 0 if calculated_cost.negative?

      @data[:total_cost] = calculated_cost
      @data
    end
  end

  def validated_options(ignore_opts)
    valid_regs = opt_regs.reject { |reg| orphan_option?(reg) }
                         .map(&:registerable_id)
    Option.where(id: valid_regs - ignore_opts)
  end

  def validated_slots(ignore_slots)
    TimeSlot.where(id: slot_regs.map(&:registerable_id) - ignore_slots).includes(:options)
  end
end
