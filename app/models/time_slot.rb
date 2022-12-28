# frozen_string_literal: true

class TimeSlot < ApplicationRecord
  belongs_to :event

  validates :name, :start_time, :end_time, :description, :cost, presence: true

  validates :start_time, comparison: { greater_than_or_equal_to: Time.zone.today, less_than_or_equal_to: :end_time }
  validates :end_time, comparison: { greater_than_or_equal_to: Time.zone.today }
  validates_comparison_of :end_time, greater_than_or_equal_to: :start_time

  validates :description, length: { minimum: 10 }

  validates :cost, comparison: { greater_than_or_equal_to: 0, less_than: 50_000 }
end
