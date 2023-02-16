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

    spot_cost = courses['1'] * num_regs
    @breakdown << "スポット1回 x #{num_regs}: #{spot_cost}円\n" unless spot_cost.zero?
    spot_cost
  end

  def calc_adjustments
    pp = pointless_price if niche_case?
    return pp unless pp.nil?

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
    @breakdown.prepend("Total course cost is #{course_cost} for #{slot_regs.size}\n")
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
  def pointless_price
    connection_cost = children.find_by(level: :kindy).full_days(event) * 184
    @breakdown << "#{connection_cost}yen adjustment applied because your child is a member kindergartener who is attending more than 0 but less than 2 full days"
    connection_cost
  end

  def slot_regs
    registrations.where(registerable_type: 'TimeSlot')
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
