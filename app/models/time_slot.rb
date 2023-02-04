# frozen_string_literal: true

# Represents an event time slot
# Must have an event
class TimeSlot < ApplicationRecord
  belongs_to :event
  delegate :school, to: :event
  delegate :area, to: :event

  has_many :options, as: :optionable,
                     dependent: :destroy
  has_many :option_registrations, through: :options,
                                  source: :registrations
  has_many :registrations, as: :registerable,
                           dependent: :destroy
  has_many :children, through: :registrations
  has_many :coupons, as: :couponable,
                     dependent: :destroy

  has_many_attached :images

  # Validations
  validates :name, :start_time, :end_time, :description, :cost, :registration_deadline, presence: true

  validates :start_time, comparison: { greater_than_or_equal_to: Time.zone.today.midnight, less_than: :end_time }
  validates :end_time, comparison: { greater_than_or_equal_to: Time.zone.today.midnight }
  validates_comparison_of :end_time, greater_than: :start_time
  validates :registration_deadline, comparison: { less_than_or_equal_to: :start_time, greater_than: Time.zone.now }

  validates :description, length: { minimum: 10 }

  validates :cost, numericality: { greater_than_or_equal_to: 0, less_than: 50_000, only_integer: true }

  # Set scopes for time slot status
  scope :past_slots, -> { where('end_time < ?', Time.zone.now) }
  scope :todays_slots, lambda {
    where('start_time > ? and end_time < ?',
          Time.zone.today.midnight,
          Time.zone.tomorrow.midnight)
  }
  scope :future_slots, -> { where('start_time >= ?', Time.zone.now) }

  # These convert the start/end datetimes into something more useful for display
  def date
    start_time.to_date.to_s
  end

  def times
    "#{start_time.strftime('%I:%M%p')} - #{end_time.strftime('%I:%M%p')}"
  end

  # List all children at the slot's school,
  # plus those attending from different schools
  def possible_children
    children.where.not(school: school).or(Child.where(school: school)).distinct
  end
end
