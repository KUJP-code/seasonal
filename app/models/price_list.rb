# frozen_string_literal: true

# Handles database records for Price Lists
class PriceList < ApplicationRecord
  # Allow separate fields for courses
  attr_accessor :course1, :course5, :course10, :course15, :course20, :course25, :course30

  before_validation :set_courses

  has_many :member_events, dependent: nil,
                           class_name: 'Event',
                           foreign_key: :member_prices_id,
                           inverse_of: :member_prices
  has_many :non_member_events, dependent: nil,
                               class_name: 'Event',
                               foreign_key: :non_member_prices_id,
                               inverse_of: :non_member_prices

  validates :courses, presence: true

  # Public methods
  # Simplifies getting the list of events using a given price list
  def events
    member_events.or(non_member_events)
  end

  private

  def set_courses
    hash = {
      '1' => course1,
      '5' => course5,
      '10' => course10,
      '15' => course15,
      '20' => course20,
      '25' => course25,
      '30' => course30
    }

    self.courses = hash
  end
end
