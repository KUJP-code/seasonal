# frozen_string_literal: true

# Represents adjustments to the price of registrations
class Adjustment < ApplicationRecord
  after_commit :update_invoice

  belongs_to :invoice

  # Validations
  validates :reason, :change, presence: true

  private

  def update_invoice
    invoice.calc_cost
  end
end
