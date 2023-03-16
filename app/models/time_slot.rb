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

  belongs_to :morning_slot, class_name: 'TimeSlot', optional: true
  has_one :afternoon_slot, class_name: 'TimeSlot',
                           foreign_key: :morning_slot_id,
                           dependent: :destroy,
                           inverse_of: :morning_slot

  has_one_attached :image

  # Validations
  validates :name, :start_time, :end_time, :description, :registration_deadline, presence: true

  validates :start_time, comparison: { greater_than_or_equal_to: Time.zone.today.midnight, less_than: :end_time }
  validates :end_time, comparison: { greater_than_or_equal_to: Time.zone.today.midnight }
  validates_comparison_of :end_time, greater_than: :start_time
  validates :registration_deadline, comparison: { less_than_or_equal_to: :start_time, greater_than: Time.zone.now }

  validates :description, length: { minimum: 10 }

  # Scopes
  # For time slot status
  scope :past_slots, -> { where('end_time < ?', Time.zone.now).order(start_time: :desc) }
  scope :todays_slots, lambda {
    where('start_time > ? and end_time < ?',
          Time.zone.today.midnight,
          Time.zone.tomorrow.midnight).order(start_time: :asc)
  }
  scope :future_slots, -> { where('start_time >= ?', Time.zone.now).order(start_time: :asc) }

  # For type of time slot
  scope :morning, -> { where(morning: true).order(start_time: :asc) }
  scope :afternoon, -> { where(morning: false).order(start_time: :asc) }

  # Public methods
  # Returns arrival time if different to slot start time, otherwise blank string
  def arrival_time(child)
    arrival_option = child.options.find_by(category: 'arrival', optionable_id: id, optionable_type: 'TimeSlot')

    if arrival_option
      "#{(start_time + arrival_option.modifier.minutes).strftime('%I:%M%p')} ~"
    else
      ''
    end
  end

  # These convert the start/end datetimes into something more useful for display
  def date
    start_time.to_date.to_s
  end

  # Returns departure time if different to slot end time, otherwise blank string
  def departure_time(child)
    departure_option = child.options.find_by(category: 'departure', optionable_id: id, optionable_type: 'TimeSlot')

    if departure_option
      "~ #{(end_time + departure_option.modifier.minutes).strftime('%I:%M%p')}"
    else
      ''
    end
  end

  def f_end_time
    end_time.strftime('%I:%M%p')
  end

  def f_start_time
    start_time.strftime('%I:%M%p')
  end

  def times
    "#{f_start_time} - #{f_end_time}"
  end

  # List all children at the slot's school,
  # plus those attending from different schools
  def possible_children
    children.where.not(school: school).or(Child.where(school: school)).distinct
  end
end
