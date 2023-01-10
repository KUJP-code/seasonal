# frozen_string_literal: true

# Represents adjustments to the price of registrations
class Adjustment < ApplicationRecord
  belongs_to :registration

  # Track changes with PaperTrail
  has_paper_trail

  # Validations
  validates :reason, :change, presence: true
  validates :change, comparison: { less_than: 0, other_than: nil, greater_than: :reg_adj_cost }

  private

  def reg_adj_cost
    -registration.adjusted_cost
  end
end
