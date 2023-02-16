# frozen_string_literal: true

# Handles data for customer Invoices
class Invoice < ApplicationRecord
  belongs_to :parent, class_name: 'User'
  has_many :children, through: :parent
  belongs_to :event

  has_many :registrations, dependent: :destroy
  accepts_nested_attributes_for :registrations
  has_many :adjustments, dependent: :destroy

  # Track changes with Paper Trail
  has_paper_trail

  # Validations
  validates :total_cost, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def calc_cost
    @breakdown = +''
    course_cost = calc_course_cost

    adjustments = calc_adjustments

    calculated_cost = course_cost + adjustments
    update_cost(calculated_cost)
  end

  private

  # Recursively finds the next largest course for given number of registrations
  # The 30 and 35 can be hardcoded since I'm told the number of courses
  # doesn't change
  def best_price(num_regs, courses)
    if num_regs >= 35
      @breakdown << "- 30回コース: #{courses['30']}円\n"
      return courses['30'] + best_price(num_regs - 30, courses)
    end

    course = nearest_five(num_regs)
    cost = courses[course.to_s]
    @breakdown << "- #{course}回コース: #{cost}円\n" unless cost.nil?
    return cost + best_price(num_regs - course, courses) unless num_regs < 5

    return spot_use(num_regs, courses) unless niche_case?

    pointless_price(num_regs, courses) if niche_case?
  end

  def calc_adjustments
    0
  end

  def calc_course_cost
    course_cost = if children.all?(&:member?)
                    best_price(slot_regs.size, member_prices)
                  elsif children.none?(&:member?)
                    best_price(slot_regs.size, non_member_prices)
                  else
                    mixed_children
                  end
    @breakdown.prepend("Total course cost is #{course_cost}yen for #{slot_regs.size} registrations\n")
    course_cost
  end

  def member_prices
    event.member_prices.courses
  end

  def mixed_children
    member_children = children.select(&:member?)
    member_regs = registrations.where(child: member_children).size
    @breakdown << "For member children\n"
    member_cost = best_price(member_regs, member_prices)

    non_member_children = children.reject(&:member?)
    non_member_regs = registrations.where(child: non_member_children).size
    @breakdown << "For non-member children\n"
    non_member_cost = best_price(non_member_regs, non_member_prices)

    member_cost + non_member_cost
  end

  # Decides if we need to apply the dumb 184 yen increase
  def niche_case?
    slot_regs.size < 5 && children.any? { |c| c.kindy? && c.full_days(event).positive? }
  end

  def non_member_prices
    event.non_member_prices.courses
  end

  def opt_regs
    registrations.where(registerable_type: 'Option')
  end

  # Calculates how many times we need to apply the dumb 184 yen increase
  # This does not deal with the even less likely case of there being two kindy kids registered for one full day each
  def pointless_price(num_regs, courses)
    days = children.find_by(level: :kindy).full_days(event)
    connection_cost = days * (courses['1'] + 184)
    @breakdown << "スポット1回(13:30~18:30) x #{days}: #{connection_cost}yen\n"
    connection_cost + spot_use(num_regs - days, courses)
  end

  def slot_regs
    registrations.where(registerable_type: 'TimeSlot')
  end

  def spot_use(num_regs, courses)
    spot_cost = num_regs * courses['1']
    @breakdown << "スポット1回(午前・15:00~18:30) x #{num_regs}: #{spot_cost}円\n" unless spot_cost.zero?
    spot_cost
  end

  # Finds the nearest multiple of 5 to the passed integer
  # Because courses are in multiples of 5, other than spot use
  def nearest_five(num)
    (num / 5).floor(0) * 5
  end

  # Updates total cost and summary once calculated/generated
  def update_cost(new_cost)
    self.total_cost = new_cost
    self.summary = @breakdown
    save
  end
end
