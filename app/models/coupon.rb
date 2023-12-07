# frozen_string_literal: true

class Coupon < ApplicationRecord
  belongs_to :couponable, polymorphic: true
end
