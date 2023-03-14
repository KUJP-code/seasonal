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
  has_many :time_slots, through: :registrations,
                        source: :registerable,
                        source_type: 'TimeSlot'
  has_many :options, through: :registrations,
                     source: :registerable,
                     source_type: 'Option'
  has_many :adjustments, dependent: :destroy

  # Track changes with Paper Trail
  has_paper_trail

  # Validations
  validates :total_cost, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def calc_cost
    @breakdown = +''
    course_cost = calc_course_cost
    option_cost = calc_option_cost
    adjustments = calc_adjustments
    generate_details

    calculated_cost = course_cost + adjustments + option_cost
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
    repeater_discount if !child.member? && child.events.distinct.size > 1 && slot_regs.size > 9

    generic_adj = adjustments.reduce(0) { |sum, adj| sum + adj.change }
    adjustments.each do |adj|
      @breakdown << "<p>Adjustment of #{adj.change.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}円 applied because #{adj.reason}</p>"
    end

    generic_adj
  end

  def calc_course_cost
    course_cost = if child.member?
                    best_price(slot_regs.size, member_prices)
                  else
                    best_price(slot_regs.size, non_member_prices)
                  end
    @breakdown.prepend(
      "<h3>Course cost:</h3>
      <p>#{course_cost.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}円 for #{slot_regs.size} registrations</p>"
    )
    course_cost
  end

  def calc_option_cost
    return 0 if opt_regs.size.zero?

    opt_cost = options.reduce(0) { |sum, opt| sum + opt.cost }
    @breakdown << "<h3>Option cost:</h3>
                   <p>#{opt_cost.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}円 for #{options.size} options</p>"
    options.group(:name).sum(:cost).each do |name, cost|
      @breakdown << "<p>- #{name} x #{options.where(name: name).count}: #{cost.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}円</p>"
    end
    opt_cost
  end

  def generate_details
    @breakdown.prepend(
      "<div id='key_info'><h1>Invoice: #{id}</h1>
      <h2>Child: #{child.name}</h2>
      <h2>For #{event.name} at #{event.school.name}</h2>"
    )
    @breakdown << "</div><div id='details'><h1>Invoice details:</h1>"

    e_opt_regs = opt_regs.where(registerable: event.options)
    unless e_opt_regs.size.zero?
      @breakdown << '<h2>Event Options:</h2>'
      event.options.each do |opt|
        @breakdown << "<p>- #{opt.name}: #{opt.cost.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}円</p>"
      end
    end

    @breakdown << '<h2>Registration List</h2>'
    slot_regs.includes(registerable: :options).find_each do |slot_reg|
      next unless slot_reg.registerable.morning

      slot = slot_reg.registerable
      @breakdown << "<div class='slot_regs'><p>#{slot.name}</p>"
      slot.options.each do |opt|
        next unless registrations.find_by(registerable: opt)

        @breakdown << "<p> - #{opt.name}: #{opt.cost.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}円</p>"
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
    # FIXME: 500 is a placeholder value til Leroy tells me the actual figure
    unless adjustments.find_by(change: 500, reason: 'because first time children must purchase a hat')
      adjustments.create(
        change: 500,
        reason: 'because first time children must purchase a hat'
      )
    end
  end

  def member_prices
    event.member_prices.courses
  end

  # Decides if we need to apply the dumb 184 円 increase
  def niche_case?
    slot_regs.size < 5 && child.kindy? && child.full_days(event, time_slots.ids).positive?
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
    @breakdown << "<p>スポット1回(13:30~18:30) x #{days}: #{extension_cost.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}円</p>"
    spot_cost = spot_use(num_regs - days, courses)
    extension_cost + spot_cost
  end

  def repeater_discount
    unless adjustments.find_by(change: -10_000, reason: 'repeater discount')
      adjustments.create(
        change: -10_000,
        reason: 'repeater discount'
      )
    end
  end

  def spot_use(num_regs, courses)
    spot_cost = num_regs * courses['1']
    unless spot_cost.zero?
      @breakdown << "<p>スポット1回(午前・15:00~18:30) x #{num_regs}: #{spot_cost.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}円</p>"
    end
    spot_cost
  end

  # Updates total cost and summary once calculated/generated
  def update_cost(new_cost)
    self.total_cost = new_cost
    @breakdown << "<h2 id='final_cost'>Final cost is #{new_cost.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}円</h2>"
    generate_template
    self.summary = @breakdown
    save
  end
end
