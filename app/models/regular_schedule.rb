# frozen_string_literal: true

# Controls data for a child's usual schedule
class RegularSchedule < ApplicationRecord
  WEEKDAYS = %w[monday tuesday wednesday thursday friday].freeze
  FALLBACK_MONTHS = 5

  belongs_to :child
  before_validation :normalize_month

  validates :month, presence: true
  validates :child_id, uniqueness: { scope: :month }, if: -> { month.present? }

  has_paper_trail

  acts_as_copy_target

  def self.default_month(date = Time.zone.today)
    (date.day >= 21 ? date.next_month : date).beginning_of_month
  end

  def days
    "#{'月, ' if monday}#{'火, ' if tuesday}#{'水, ' if wednesday}" \
    "#{'木, ' if thursday}#{'金' if friday}".chomp(', ')
  end

  def en_days
    {
      'Monday' => monday,
      'Tuesday' => tuesday,
      'Wednesday' => wednesday,
      'Thursday' => thursday,
      'Friday' => friday
    }
  end

  def has?(date)
    return false unless month == date.to_date.beginning_of_month

    weekday?(date)
  end

  def weekday?(date)
    day = date.strftime('%A').downcase
    return false unless WEEKDAYS.include?(day)

    public_send(day)
  end

  private

  def normalize_month
    self.month = month.beginning_of_month if month
  end
end
