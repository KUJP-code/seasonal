# frozen_string_literal: true

module OptionCalculator
  private

  def calc_option_cost(opts)
    # Prevent multiple siblings registering for same event option
    opts -= duplicated_event_opts(opts)
    @data[:opt_cost] = opts.reduce(0) { |sum, opt| sum + opt.cost }
  end

  def duplicated_event_opts(opts)
    duplicated = opts.select do |opt|
      opt.event? &&
        child.siblings.any? { |s| s.options.include?(opt) }
    end
    duplicated.each do |opt|
      opt_regs.find_by(registerable_id: opt.id)&.destroy
    end
    duplicated
  end

  # Remove options if their slot is no longer registered for
  def orphan_option?(opt_reg)
    # Exclude event options from the check
    return false if event.options.ids.include?(opt_reg['registerable_id'].to_i)
    return true if slot_regs.empty?

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
