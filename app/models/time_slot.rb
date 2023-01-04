# frozen_string_literal: true

# Represents an event time slot
# Must have an event
class TimeSlot < ApplicationRecord
  belongs_to :event
  delegate :school, to: :event
  delegate :area, to: :event

  has_many :registrations, as: :registerable,
                           dependent: :destroy
  has_many :children, through: :registrations

  validates :name, :start_time, :end_time, :description, :cost, presence: true

  validates :start_time, comparison: { greater_than_or_equal_to: Time.zone.today.midnight, less_than: :end_time }
  validates :end_time, comparison: { greater_than_or_equal_to: Time.zone.today.midnight }
  validates_comparison_of :end_time, greater_than: :start_time

  validates :description, length: { minimum: 10 }

  validates :cost, comparison: { greater_than_or_equal_to: 0, less_than: 50_000 }

  # Set scopes for time slot status
  scope :past_slots, -> { where('end_time < ?', Time.zone.today.midnight) }
  scope :todays_slots, lambda {
    where('start_time > ? and end_time < ?',
          Time.zone.today.midnight,
          Time.zone.tomorrow.midnight)
  }
  scope :future_slots, -> { where('start_time >= ?', Time.zone.tomorrow.midnight) }
end
