# frozen_string_literal: true

# Represents adjustments to the price of registrations
class Adjustment < ApplicationRecord
  belongs_to :invoice

  # Validations
  validates :reason, :change, presence: true
end
