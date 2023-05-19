# frozen_string_literal: true

# Represents adjustments to the price of registrations
class Adjustment < ApplicationRecord
  belongs_to :invoice

  # Validations
  validates :change, :reason, presence: true
end
