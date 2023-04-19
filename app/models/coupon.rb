# frozen_string_literal: true

# Represents a coupon which can be used for a discount
class Coupon < ApplicationRecord
  belongs_to :couponable, polymorphic: true
end
