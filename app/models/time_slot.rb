# frozen_string_literal: true

class TimeSlot < ApplicationRecord
  belongs_to :event
  delegate :school, to: :event

  validates :name, :start_time, :end_time, :description, :cost, presence: true

  validates :start_time, comparison: { greater_than_or_equal_to: Time.zone.today, less_than: :end_time }
  validates :end_time, comparison: { greater_than_or_equal_to: Time.zone.today }
  validates_comparison_of :end_time, greater_than: :start_time

  validates :description, length: { minimum: 10 }

  validates :cost, comparison: { greater_than_or_equal_to: 0, less_than: 50_000 }

  # Set scopes for time slot status
  scope :past_slots, -> { where('end_time < ?', Time.zone.today) }
  scope :todays_slots, -> { where('start_time > ? and end_time < ?', Time.zone.yesterday, Time.zone.tomorrow) }
  scope :future_slots, -> { where('start_time >= ?', Time.zone.tomorrow) }
end
