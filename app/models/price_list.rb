# frozen_string_literal: true

# Handles database records for Price Lists
class PriceList < ApplicationRecord
  has_many :member_events, dependent: nil,
                           class_name: 'Event',
                           foreign_key: :member_price_id,
                           inverse_of: :member_price
  has_many :non_member_events, dependent: nil,
                               class_name: 'Event',
                               foreign_key: :non_member_price_id,
                               inverse_of: :non_member_price

  enum :category, member: 0,
                  non_member: 1,
                  default: :non_member

  validates :courses, presence: true

  # Public methods
  # Simplifies getting the list of events using a given price list
  def events
    member_events.or(non_member_events)
  end
end
