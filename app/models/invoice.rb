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

  # TODO: this works but is a monstrosity, clean it up/separate out into
  # smaller methods which can maybe be called independently
  def calc_cost
    # The plus is necessary to make sure it's not a frozen string
    @breakdown = +"Invoice##{id}\nCustomer: #{parent.name}\nEvent: #{event.name}\n"

    children_cost = parent.children.reduce(0) do |memo, child|
      # Calculates the cost of the child's slot regs using courses and 
      # adds to summary
      child_reg_cost = child_cost(child)

      child_slot_regs = slot_regs.where(child: child)
      @breakdown << "Course cost for #{child.name} is #{child_reg_cost}yen for #{child_slot_regs.size} registrations.\n"

      # Calculates the total option cost and adds it to summary
      child_opt_cost = opt_regs.where(child: child).reduce(0) { |sum, reg| reg.registerable.cost + sum }
      @breakdown << "Total option cost for #{child.name} is #{child_opt_cost}yen\n"

      # Adds registered event options to summary if present, else add them
      # with an x
      @breakdown << "Event Options:\n"
      event.options.each do |e_opt|
        @breakdown << if child.registered?(e_opt)
                        " - #{e_opt.name} for #{e_opt.cost}\n"
                      else
                        " - #{e_opt.name}: 𐄂\n"
                      end
      end

      # Adds slot regs to the summary
      @breakdown << "Registered for:\n"

      child_slot_regs.each do |reg|
        @breakdown << "- #{reg.registerable.name}\n"

        # Adds options for that slot to the summary if any
        child_opt_regs = opt_regs.where(child: child, registerable: reg.registerable.options)
        next if child_opt_regs.size.zero?

        @breakdown << " Options:\n"
        child_opt_regs.each do |opt_reg|
          opt = opt_reg.registerable
          @breakdown << "   - #{opt.name} for #{opt.cost}yen\n"
        end
      end

      memo + child_reg_cost + child_opt_cost
    end

    # Calculate change due to adjustments and add to summary
    adjustment_change = adjustments.reduce(0) { |sum, adj| adj.change + sum }
    adjustments.each do |adjustment|
      @breakdown << "An adjustment of #{adjustment.change} was applied because #{adjustment.reason}\n"
    end

    # Calculate total cost and add to summary
    calculated_cost = children_cost + adjustment_change
    @breakdown << "Your final total is #{calculated_cost}"
    update_cost(calculated_cost)
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

  # Recursively finds the next largest course for given number of registrations
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

  # Updates total cost and summary once calculated/generated
  def update_cost(new_cost)
    self.total_cost = new_cost
    self.summary = @breakdown
    save
  end
end
