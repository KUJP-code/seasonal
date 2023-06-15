# frozen_string_literal: true

# Represents an event time slot
# Must have an event
class TimeSlot < ApplicationRecord
  belongs_to :event
  has_one :school, through: :event
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
  validates :name, :start_time, :end_time, presence: true

  validates_comparison_of :end_time, greater_than: :start_time

  # Map category integer in db to a string
  enum :category, seasonal: 0,
                  special: 1,
                  party: 2,
                  outdoor: 3,
                  default: :seasonal

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
  # Consolidates manual closing and automatic closing into one check
  def closed?
    closed || Time.zone.now > end_time - 1.day
  end

  # These convert the start/end datetimes into something more useful for display
  def date
    start_time.strftime('%m月%d日') + ja_day
  end

  def day
    start_time.strftime('%A')
  end

  def f_end_time
    end_time.strftime('%I:%M%p')
  end

  def f_start_time
    start_time.strftime('%I:%M%p')
  end

  def ja_day
    en_day = start_time.strftime('%A')

    "（#{DAYS[en_day]}）"
  end

  def times
    "#{f_start_time} - #{f_end_time}"
  end

  DAYS = {
    'Sunday' => '日',
    'Monday' => '月',
    'Tuesday' => '火',
    'Wednesday' => '水',
    'Thursday' => '木',
    'Friday' => '金',
    'Saturday' => '土' 
  }
end
