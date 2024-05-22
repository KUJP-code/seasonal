# frozen_string_literal: true

module OptionCalculator
  private

  def calc_option_cost(opts)
    # Prevent multiple siblings registering for same event option
    check_event_opts
    @data[:opt_cost] = opts.reduce(0) { |sum, opt| sum + opt.cost }
  end

  def check_event_opts
    opt_regs.where(registerable_id: event.options.ids,
                   registerable_type: 'Option').find_each do |reg|
      reg.destroy if child.siblings.any? { |s| s.options.include?(reg.registerable) }
    end
  end

  # Remove options if their slot is no longer registered for
  def orphan_option?(opt_reg)
    return true if slot_regs.empty?
    # Exclude event options from the check
    return false if event.options.ids.include?(opt_reg['registerable_id'].to_i)

    option = Option.find(opt_reg['registerable_id'])
    # If for special day extension, only delete if neither registered
    if option.extension? || option.k_extension?
      return slot_regs.none? do |r|
               r.registerable.special?
             end
    end

    slot_regs.none? { |s_reg| s_reg.registerable_id == option.optionable_id }
  end
end
