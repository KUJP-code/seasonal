# frozen_string_literal: true

# Represents a coupon which can be used for a discount on
# an option or time slot
class Coupon < ApplicationRecord
  belongs_to :couponable, polymorphic: true

  # Validations
  validates :code, :name, :description, :discount, presence: true
  validates :discount, numericality: { less_than_or_equal_to: 1, greater_than: 0 }

  # Scopes for type
  scope :slot_coupons, -> { where(couponable_type: 'TimeSlot') }
  scope :option_coupons, -> { where(couponable_type: 'Option') }
end
