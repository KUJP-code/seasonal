# frozen_string_literal: true

# Represents adjustments to the price of registrations
class Adjustment < ApplicationRecord
  belongs_to :registration

  # Track changes with PaperTrail
  has_paper_trail
end
