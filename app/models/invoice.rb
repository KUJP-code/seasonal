# frozen_string_literal: true

# Handles data for customer Invoices
class Invoice < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper

  belongs_to :child
  delegate :parent, to: :child
  belongs_to :event

  has_many :registrations, dependent: :destroy
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

  # Track changes with Paper Trail
  has_paper_trail ignore: [:seen_at]

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

    if num_regs >= 35
      @breakdown << "<p>- 30回コース: #{courses['30']}円</p>"
      return courses['30'] + best_price(num_regs - 30, courses)
    end

    course = nearest_five(num_regs)
    cost = courses[course.to_s]
    @breakdown << "<p>- #{course}回コース: #{cost.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}円</p>" unless cost.nil?
    return cost + best_price(num_regs - course, courses) unless num_regs < 5

    return spot_use(num_regs, courses) unless child.member? && niche_case?

    pointless_price(num_regs, courses)
  end

  def calc_adjustments
    hat_adjustment if child.needs_hat?
    repeater_discount if !child.member? && child.events.distinct.size > 1 && slot_regs.size - @ignore_slots.size > 9

    generic_adj = adjustments.reduce(0) { |sum, adj| sum + adj.change }
    adjustments.each do |adj|
      @breakdown << "<p>Adjustment of #{adj.change.to_s.reverse.gsub(/(\d{3})(?=\d)/,
                                                                     '\\1,').reverse}円 applied because #{adj.reason}</p>"
    end

    generic_adj
  end

  def calc_course_cost
    num_regs = slot_regs.size - @ignore_slots.size
    course_cost = if child.member?
                    best_price(num_regs, member_prices)
                  else
                    best_price(num_regs, non_member_prices)
                  end
    @breakdown.prepend(
      "<h3>Course cost:</h3>
      <p>#{course_cost.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}円 for #{num_regs} registrations</p>"
    )
    course_cost
  end

  def calc_option_cost
    opt_cost = opt_regs.reject { |reg| @ignore_opts.include?(reg.id) }.reduce(0) { |sum, reg| sum + reg.registerable.cost }
    @breakdown << "<h3>Option cost:</h3>
                   <p>#{opt_cost.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}円 for #{opt_regs.size - @ignore_opts.size}  options<p>"
    options.group(:name).sum(:cost).each do |name, cost|
      @breakdown << "<p>- #{name} x #{options.where(name: name).count}: #{cost.to_s.reverse.gsub(/(\d{3})(?=\d)/,
                                                                                                 '\\1,').reverse}円</p>"
    end
    opt_cost
  end

  def generate_details
    @breakdown.prepend(
      "<div id='key_info'><h1>Invoice: #{id}</h1>\n<h2>Child: #{child.name}</h2>\n<h2>For #{event.name} at #{event.school.name}</h2>\n"
    )
    @breakdown << "</div><div id='details'><h1>Invoice details:</h1>\n"

    e_opt_regs = opt_regs.where(registerable: event.options)
    unless e_opt_regs.empty?
      @breakdown << "<h2>Event Options:</h2>\n"
      event.options.each do |opt|
        @breakdown << "<p>- #{opt.name}: #{opt.cost.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}円</p>\n"
      end
    end

    @breakdown << "<h2>Registration List</h2>\n"
    slot_regs.each do |slot_reg|
      next if @ignore_slots.include?(slot_reg.id)

      slot = slot_reg.registerable

      @breakdown << if slot.morning
                      "<div class='slot_regs'><p>#{slot.name}</p>\n"
                    else
                      "<div class='slot_regs'><p>#{slot.name} (午後)</p>\n"
                    end

      slot.options.each do |opt|
        opt_reg = opt_regs.find_by(registerable_id: opt.id)
        next if opt_reg.nil? || @ignore_opts.include?(opt_reg.id)

        @breakdown << "<p> - #{opt.name}: #{opt.cost.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}円</p>\n"
      end
      @breakdown << '</div>'
    end
    @breakdown << '</div>'
  end

  # TODO: I'm guessing this will not be the final message
  def generate_template
    template = +''
    template << 'Hello Dear Sir/Madam, this is the start of our email template!'
    template << strip_tags(@breakdown)
    template << "That's all folks! End of email"
    self.email_template = template
  end

  def hat_adjustment
    unless child.invoices.where(event: event).any? do |invoice|
             invoice.adjustments.find_by(change: 1_100, reason: 'because first time children must purchase a hat')
           end
      adjustments.new(
        change: 1_100,
        reason: 'because first time children must purchase a hat'
      )
    end
  end

  def member_prices
    event.member_prices.courses
  end

  # Decides if we need to apply the dumb 184 円 increase
  def niche_case?
    slot_regs.size - @ignore_slots.size < 5 && child.kindy? && child.full_days(event, time_slots.ids).positive?
  end

  def non_member_prices
    event.non_member_prices.courses
  end

  # Finds the nearest multiple of 5 to the passed integer
  # Because courses are in multiples of 5, other than spot use
  def nearest_five(num)
    (num / 5).floor(0) * 5
  end

  # Calculates how many times we need to apply the dumb 184円 increase
  # This does not deal with the even less likely case of there being two kindy kids registered for one full day each
  def pointless_price(num_regs, courses)
    days = child.full_days(event, time_slots.ids)
    extension_cost = days * (courses['1'] + 184)
    @breakdown << "<p>スポット1回(13:30~18:30) x #{days}: #{extension_cost.to_s.reverse.gsub(/(\d{3})(?=\d)/,
                                                                                             '\\1,').reverse}円</p>\n"
    spot_cost = spot_use(num_regs - days, courses)
    extension_cost + spot_cost
  end

  def repeater_discount
    unless child.invoices.where(event: event).any? do |invoice|
             invoice.adjustments.find_by(change: -10_000, reason: 'repeater discount')
           end
      adjustments.new(
        change: -10_000,
        reason: 'repeater discount'
      )
    end
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
    @breakdown << "<h2 id='final_cost'>Final cost is #{new_cost.to_s.reverse.gsub(/(\d{3})(?=\d)/,
                                                                                  '\\1,').reverse}円</h2>\n"
    generate_template
    self.summary = @breakdown
    save unless new_record?
  end
end
