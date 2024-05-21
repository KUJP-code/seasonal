# frozen_string_literal: true

module InvoiceCalculatable
  extend ActiveSupport::Concern
  include CourseCalculator

  included do
    def calc_cost(ignore_slots = [], ignore_opts = [])
      @ignore_slots = ignore_slots
      @ignore_opts = ignore_opts
      @breakdown = +''
      @data = {
        child:,
        options: Option.where(id: opt_regs.map(&:registerable_id) - @ignore_opts),
        time_slots: TimeSlot.where(id: slot_regs.map(&:registerable_id) - @ignore_slots)
      }
      @data[:num_regs] = @data[:time_slots].size
      calc_course_cost(@data[:time_slots])
      option_cost = calc_option_cost
      adjustments = calc_adjustments(slot_regs.size - @ignore_slots.size)
      generate_details(@data)

      calculated_cost = @data[:course_cost] + adjustments + option_cost
      calculated_cost = 0 if calculated_cost.negative?
      update_cost(calculated_cost)
      @data[:total_cost] = calculated_cost
      @data
    end
  end

  private

  def calc_option_cost
    # Prevent multiple siblings registering for same event option
    check_event_opts
    # Ignore options to be deleted on confirmation screen
    valid_opt_regs = opt_regs.reject do |reg|
      @ignore_opts.include?(reg.id) || orphan_option?(reg)
    end
    opt_cost = valid_opt_regs.reduce(0) { |sum, reg| sum + reg.registerable.cost }
    if opt_regs.size.positive?
      @breakdown << "<h4 class='fw-semibold'>オプション:</h4>
                     <div class='d-flex flex-column align-items-start gap-1'>
                     <p>#{yenify(opt_cost)} (#{valid_opt_regs.size}オプション)<p>"
    end

    # Find the options on this invoice, even if not saved
    temp_opts = {}
    opt_regs.each do |reg|
      next if @ignore_opts.include?(reg.id) || orphan_option?(reg)

      opt = reg.registerable
      next if opt.name == 'なし'

      if temp_opts[opt.name].nil?
        temp_opts[opt.name] = {
          cost: opt.cost,
          count: 1
        }
      else
        temp_opts[opt.name][:count] += 1
        temp_opts[opt.name][:cost] += opt.cost
      end
    end
    # Display options with count and cost
    temp_opts.each do |name, _|
      @breakdown << "<p>- #{name} x #{temp_opts[name][:count]}: #{yenify(temp_opts[name][:cost])}</p>"
    end

    @breakdown << '</div>'
    opt_cost
  end

  def check_event_opts
    opt_regs.where(registerable_id: event.options.ids,
                   registerable_type: 'Option').find_each do |reg|
      reg.destroy if child.siblings.any? { |s| s.options.include?(reg.registerable) }
    end
  end

  def calc_adjustments(num_regs)
    return 0 unless adjustments.size.positive? || needs_hat? || first_time?(num_regs) || repeater?

    @breakdown << '<h4 class="fw-semibold text-start">調整:</h4>'
    @breakdown << '<div class="d-flex flex-column align-items-start gap-1">'
    hat_adjustment if needs_hat?
    first_time_adjustment if first_time?(num_regs)
    repeater_discount if repeater?
    generic_adj = adjustments.reduce(0) { |sum, adj| sum + adj.change }
    adjustments.each do |adj|
      @breakdown << "<p>#{adj.reason}: #{yenify(adj.change)}</p>"
    end
    @breakdown << '</div>'

    generic_adj
  end

  def first_time?(num_regs)
    child.external? && child.first_seasonal && num_regs.positive?
  end

  def first_time_adjustment
    registration_cost = 1_100
    reason = '初回登録料(初めてシーズナルスクールに参加する非会員の方)'
    return if adjustments.any? { |adj| adj.change == registration_cost && adj.reason == reason } ||
              child.adjustments.any? do |adj|
                adj.change == registration_cost && adj.reason == reason
              end

    adjustments.new(change: registration_cost, reason:)
  end

  def hat_adjustment
    hat_cost = 1_100
    hat_reason = '帽子代(野外アクティビティに参加される方でKids UP帽子をお持ちでない方のみ)'
    return if hat_adj_exists(hat_cost, hat_reason)

    adjustments.new(change: hat_cost, reason: hat_reason)
  end

  def hat_adj_exists(hat_cost, hat_reason)
    adjustments.any? { |adj| adj.change == hat_cost && adj.reason == hat_reason } ||
      child.adjustments.any? { |adj| adj.change == hat_cost && adj.reason == hat_reason }
  end

  def member_prices
    event.member_prices.courses
  end

  # This one actually refers to the child needing a hat or not
  def needs_hat?
    return false if child.received_hat || child.internal?

    # They only need one if registered for an outdoor activity now
    slot_regs.any? { |reg| reg.registerable.category == 'outdoor' }
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
    unless spot_cost.zero? || @breakdown.nil?
      @breakdown << "<p>- 1回コース x #{num_regs}: #{yenify(spot_cost)}</p>\n"
    end
    spot_cost
  end

  def repeater?
    # FIXME: Temp exception for 2023 repeater discount till all confirmed
    if event.name == 'Kids UP ウインタースクール 2023'
      child.external? && child.first_seasonal == false && slot_regs.size - @ignore_slots.size > 9
    else
      child.external? && child.first_seasonal == false && slot_regs.size - @ignore_slots.size > 4
    end
  end

  def repeater_discount
    discount = -10_000
    reason = '非会員リピーター割引(以前シーズナルスクールに参加された非会員の方)'
    if adjustments.any? { |adj| adj.change == discount && adj.reason == reason } ||
       repeater_applied_this_event?(discount, reason)
      return
    end

    adjustments.new(change: discount, reason:)
  end

  def repeater_applied_this_event?(discount, reason)
    adjustments = child.invoices
                       .where(event_id:)
                       .where.not(id:)
                       .map(&:adjustments).flatten
    adjustments.find { |a| a.change == discount && a.reason == reason }
  end

  # Updates total cost and summary once calculated/generated
  def update_cost(new_cost)
    self.total_cost = new_cost
    @breakdown << "<h2 id='final_cost' class='fw-semibold text-start'>合計（税込）: #{yenify(new_cost)}</h2>\n"
    self.summary = @breakdown
    new_cost
  end
end
