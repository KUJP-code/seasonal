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
    course_cost = parent.children.reduce(0) do |memo, child|
      memo + child_cost(child)
    end
    option_cost = opt_regs.reduce(0) { |sum, reg| reg.registerable.cost + sum }
    adjustment_change = adjustments.reduce(0) { |sum, adj| adj.change + sum }
    update_cost(course_cost + option_cost + adjustment_change)
  end

  def opt_regs
    registrations.where(registerable_type: 'Option')
  end

  def slot_regs
    registrations.where(registerable_type: 'TimeSlot')
  end

  private

  # Calculates cost per child
  def child_cost(child)
    courses = if child.member?
                event.member_price.courses
              else
                event.non_member_price.courses
              end
    num_regs = slot_regs.where(child: child).size.to_s
    return courses[num_regs] unless courses[num_regs].nil?

    best_course(num_regs.to_i, courses)
  end

  # Recursively finds the next largest course for the number of registrations
  def best_course(num_regs, courses)
    max_course = courses.keys.last
    return courses[max_course] + best_course(num_regs - max_course.to_i, courses) if num_regs > max_course.to_i + 5

    key = nearest_five(num_regs)
    return courses[key.to_s] + best_course(num_regs - key, courses) unless num_regs < 5

    courses['1'] * num_regs
  end

  # Finds the nearest multiple of 5 to the passed integer
  # Because courses are in multiples of 5, other than spot use
  def nearest_five(num)
    (num / 5).floor(0) * 5
  end

  def update_cost(new_cost)
    self.total_cost = new_cost
    save
  end
end
