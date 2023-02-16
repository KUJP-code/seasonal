# frozen_string_literal: true

# Handles database records for Price Lists
class PriceList < ApplicationRecord
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
end
