# frozen_string_literal: true

module InvoiceCalculatable
  extend ActiveSupport::Concern
  include AdjustmentCalculator
  include CourseCalculator
  include OptionCalculator

  included do
    def calc_cost(ignore_slots = [], ignore_opts = [])
      @ignore_slots = ignore_slots
      @ignore_opts = ignore_opts
      @breakdown = +''
      @data = {
        child:,
        options: validated_options(ignore_opts),
        time_slots: TimeSlot.where(id: slot_regs.map(&:registerable_id) - @ignore_slots)
      }
      @data[:num_regs] = @data[:time_slots].size
      calc_course_cost(@data[:time_slots])
      calc_option_cost(@data[:options])
      adj_cost = calc_adjustments(@data[:num_regs])
      generate_details(@data)

      calculated_cost = @data[:course_cost] + adj_cost + @data[:opt_cost]
      calculated_cost = 0 if calculated_cost.negative?
      update_cost(calculated_cost)
      @data[:total_cost] = calculated_cost
      @data
    end
  end

  private

  # Updates total cost and summary once calculated/generated
  def update_cost(new_cost)
    self.total_cost = new_cost
    @breakdown << "<h2 id='final_cost' class='fw-semibold text-start'>合計（税込）: #{yenify(new_cost)}</h2>\n"
    self.summary = @breakdown
    new_cost
  end
end
