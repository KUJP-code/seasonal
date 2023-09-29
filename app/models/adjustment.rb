# frozen_string_literal: true

# Represents adjustments to the price of registrations
class Adjustment < ApplicationRecord
  belongs_to :invoice

  # Validations
  validates :change, :reason, presence: true

  def reason_cost
    "#{reason}: #{change.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}円"
  end
end
