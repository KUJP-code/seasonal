# frozen_string_literal: true

# Handles data for customer Invoices
class Invoice < ApplicationRecord
  before_save :update_regs_child, :calc_cost

  belongs_to :child
  delegate :parent, to: :child
  delegate :school, to: :child
  belongs_to :event

  has_many :registrations, dependent: :destroy
  accepts_nested_attributes_for :registrations
  has_many :slot_regs, -> { where(registerable_type: 'TimeSlot') },
           class_name: 'Registration',
           dependent: :destroy,
           inverse_of: :invoice
  accepts_nested_attributes_for :slot_regs, allow_destroy: true
  has_many :opt_regs, -> { where(registerable_type: 'Option') },
           class_name: 'Registration',
           dependent: :destroy,
           inverse_of: :invoice
  accepts_nested_attributes_for :opt_regs, allow_destroy: true
  has_many :time_slots, through: :slot_regs,
                        source: :registerable,
                        source_type: 'TimeSlot'
  has_many :options, through: :opt_regs,
                     source: :registerable,
                     source_type: 'Option'
  has_many :adjustments, dependent: :destroy
  accepts_nested_attributes_for :adjustments, allow_destroy: true
  has_many :coupons, as: :couponable,
                     dependent: :destroy
  accepts_nested_attributes_for :coupons, reject_if: :all_blank

  # Track changes with Paper Trail
  has_paper_trail ignore: [:seen_at]

  # Allow export/import with postgres-copy
  acts_as_copy_target

  # Validations
  validates :total_cost, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def calc_cost(ignore_slots = [], ignore_opts = [])
    @ignore_slots = ignore_slots
    @ignore_opts = ignore_opts
    @breakdown = +''
    course_cost = calc_course_cost
    option_cost = calc_option_cost
    adjustments = calc_adjustments
    generate_details

    calculated_cost = course_cost + adjustments + option_cost
    calculated_cost = 0 if calculated_cost.negative?
    update_cost(calculated_cost)
  end

  def f_bill_date
    billing_date.strftime('%Y/%m/%d')
  end

  private

  # Recursively finds the next largest course for given number of registrations
  # The 30 and 35 can be hardcoded since I'm told the number of courses
  # doesn't change
  def best_price(num_regs, courses)
    return 0 if num_regs.zero?

    if num_regs >= 55
      @breakdown << "<p>- 50回コース: #{courses['50']}円</p>"
      return courses['50'] + best_price(num_regs - 50, courses)
    end

    course = nearest_five(num_regs)
    cost = courses[course.to_s]

    @breakdown << "<p>- #{course}回コース: #{cost.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}円</p>" unless cost.nil?
    return cost + best_price(num_regs - course, courses) unless num_regs < 5

    return spot_use(num_regs, courses) unless child.member? && niche_case?

    pointless_price(num_regs, courses)
  end

  def calc_adjustments
    @breakdown << '<h4>調整:</h4>'
    @breakdown << '<div class="d-flex flex-column gap-1">'
    hat_adjustment if needs_hat?
    first_time_adjustment if first_time?
    repeater_discount if repeater?
    generic_adj = adjustments.reduce(0) { |sum, adj| sum + adj.change }
    adjustments.each do |adj|
      @breakdown << "<p>Adjustment of #{adj.change.to_s.reverse.gsub(/(\d{3})(?=\d)/,
                                                                     '\\1,').reverse}円 applied because #{adj.reason}</p>"
    end
    @breakdown << '</div>'

    generic_adj
  end

  def calc_course_cost
    num_regs = slot_regs.size - @ignore_slots.size
    course_cost = if child.member?
                    best_price(num_regs, member_prices)
                  else
                    best_price(num_regs, non_member_prices)
                  end
    # Add cost due to automatic afternoon snacks
    snack_count = slot_regs.count { |reg| !reg.registerable.morning }
    course_cost += snack_count * 165
    @breakdown << '</div>'
    @breakdown.prepend(
      "<h4>コース:</h4>
      <div class='d-flex flex-column gap-1'>
      <p>#{course_cost.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}円 (#{num_regs}コマ)</p>
      <p>午後コースおやつ代 x #{snack_count}: #{(snack_count * 165).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}円"
    )
    course_cost
  end

  def calc_option_cost
    # Prevent multiple siblings registering for same event option
    check_event_opts
    # Ignore options to be deleted on confirmation screen
    opt_cost = opt_regs.reject do |reg|
                 @ignore_opts.include?(reg.id)
               end.reduce(0) { |sum, reg| sum + reg.registerable.cost }
    @breakdown << "<h4>オプション:</h4>
                   <div class='d-flex flex-column gap-1'>
                   <p>#{opt_cost.to_s.reverse.gsub(/(\d{3})(?=\d)/,
                                                   '\\1,').reverse}円 (#{opt_regs.size - @ignore_opts.size}オプション)<p>"

    # Find the options on this invoice, even if not saved
    temp_opts = {}
    opt_regs.each do |reg|
      opt = reg.registerable
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
      @breakdown << "<p>- #{name} x #{temp_opts[name][:count]}: #{temp_opts[name][:cost].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}円</p>"
    end

    @breakdown << '</div>'
    opt_cost
  end

  def check_event_opts
    opt_regs.where(registerable_id: event.options.ids, registerable_type: 'Option').find_each do |reg|
      reg.destroy if child.siblings.any? { |s| s.options.include?(reg.registerable) }
    end
  end

  def first_time?
    child.external? && child.events.distinct.size <= 1
  end

  def first_time_adjustment
    registration_cost = 1_100
    reason = '初回登録料(初めてシーズナルスクールに参加する非会員の方)'
    return if child.adjustments.any? { |adj| adj.change == registration_cost && adj.reason == reason }

    adjustments.new(change: registration_cost, reason: reason)
  end

  def full_days(slot_ids)
    TimeSlot.all.where(event_id: event_id, id: slot_ids, morning_slot_id: slot_ids).size
  end

  def generate_details
    @breakdown.prepend(
      "<div class='d-flex gap-3 flex-column'>\n
      <h2>#{child.name}</h2>\n
      <h3>#{event.name} @ #{event.school.name}</h3>\n
      <h4>登録番号: T7-0118-0103-7173</h4>\n"
    )
    @breakdown << "</div><h2>予約の詳細:</h2>\n"

    e_opt_regs = opt_regs.where(registerable: event.options)
    unless e_opt_regs.empty?
      @breakdown << "<h4>Event Options:</h4>\n"
      @breakdown << '<div class="d-flex gap-3 p-3 justify-content-center flex-wrap">'
      event.options.each do |opt|
        @breakdown << "<p>- #{opt.name}: #{opt.cost.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}円</p>\n"
      end
      @breakdown << '</div>'
    end

    @breakdown << "<h4>登録</h4>\n"
    @breakdown << '<div class="d-flex gap-3 p-3 justify-content-center flex-wrap">'
    slot_regs.each do |slot_reg|
      next if @ignore_slots.include?(slot_reg.id)

      slot = slot_reg.registerable

      @breakdown << if slot.morning
                      "<div class='slot_regs'><p>#{slot.name} (#{slot.date})</p>\n"
                    else
                      "<div class='slot_regs'><p>#{slot.name} (#{slot.date}) (午後)</p>\n"
                    end

      # Show details for all registered options, even unsaved
      opt_regs.select { |reg| slot.options.ids.include?(reg.registerable_id) }.each do |opt_reg|
        next if opt_reg.nil? || @ignore_opts.include?(opt_reg.id)

        opt = opt_reg.registerable
        @breakdown << "<p> - #{opt.name}: #{opt.cost.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}円</p>\n"
      end
      @breakdown << '</div>'
    end
    @breakdown << '</div>'
  end

  # TODO: I'm guessing this will not be the final message
  def generate_template
    template = +''
    template << '<h3>Hello Dear Sir/Madam, this is the start of our email template!</h3>'
    template << @breakdown
    template << "<h3>That's all folks! End of email</h3>"
    self.email_template = template
  end

  def hat_adjustment
    hat_cost = 1_100
    hat_reason = '帽子代(野外アクティビティに参加される方でKids UP帽子をお持ちでない方のみ)'
    return if child.adjustments.any? { |adj| adj.change == hat_cost && adj.reason == hat_reason }

    adjustments.new(change: hat_cost, reason: hat_reason)
  end

  def member_prices
    event.member_prices.courses
  end

  def needs_hat?
    return false if child.received_hat

    # They only need one if registered for an outdoor activity now
    time_slots.any? { |slot| slot.category == 'outdoor' }
  end

  # Decides if we need to apply the dumb 200 円 increase
  def niche_case?
    slot_regs.size - @ignore_slots.size < 5 && child.kindy && full_days(slot_regs.map(&:registerable_id)).positive?
  end

  def non_member_prices
    event.non_member_prices.courses
  end

  # Finds the nearest multiple of 5 to the passed integer
  # Because courses are in multiples of 5, other than spot use
  def nearest_five(num)
    (num / 5).floor(0) * 5
  end

  # Calculates how many times we need to apply the dumb 200円 increase
  # This does not deal with the even less likely case of there being two kindy kids registered for one full day each
  def pointless_price(num_regs, courses)
    days = full_days(slot_regs.map(&:registerable_id))
    extension_cost = days * (courses['1'] + 200)
    @breakdown << "<p>スポット1回(13:30~18:30) x #{days}: #{extension_cost.to_s.reverse.gsub(/(\d{3})(?=\d)/,
                                                                                             '\\1,').reverse}円</p>\n"
    spot_cost = spot_use(num_regs - days, courses)
    extension_cost + spot_cost
  end

  def repeater?
    child.external? && child.events.distinct.size > 1 && slot_regs.size - @ignore_slots.size > 9
  end

  def repeater_discount
    discount = -10_000
    reason = '非会員リピーター割引(以前シーズナルスクールに参加された非会員の方)'
    return if child.invoices.where(event: event).any? do |invoice|
                invoice.adjustments.find_by(change: discount, reason: reason)
              end

    adjustments.new(change: discount, reason: reason)
  end

  def spot_use(num_regs, courses)
    spot_cost = num_regs * courses['1']
    unless spot_cost.zero?
      @breakdown << "<p>スポット1回(午前・15:00~18:30) x #{num_regs}: #{spot_cost.to_s.reverse.gsub(/(\d{3})(?=\d)/,
                                                                                                    '\\1,').reverse}円</p>\n"
    end
    spot_cost
  end

  # Updates total cost and summary once calculated/generated
  def update_cost(new_cost)
    self.total_cost = new_cost
    @breakdown << "<h2 id='final_cost'>合計（税込）: #{new_cost.to_s.reverse.gsub(/(\d{3})(?=\d)/,
                                                                          '\\1,').reverse}円</h2>\n"
    generate_template
    self.summary = @breakdown
  end

  def update_regs_child
    return if registrations.empty? || registrations.first.child_id == child_id

    registrations.each do |reg|
      reg.update!(child_id: child_id)
    end
  end
end
