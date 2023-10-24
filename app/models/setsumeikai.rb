# frozen_string_literal: true

# Handles DB interactions for Setsumeikais
class Setsumeikai < ApplicationRecord
  belongs_to :school

  validates :start, :finish, :attendance_limit, presence: true
  validates :attendance_limit, comparison: { greater_than: 0 }
  validates :start, comparison: {
    greater_than: Time.zone.now, less_than: :finish
  }

  scope :upcoming, -> { where('start > ?', Time.zone.now) }
  scope :available, -> { where('attendance_limit > inquiries_count') }

  def as_json(_options = {})
    {
      id: id,
      start: start,
      end: finish,
      title: school.name
    }
  end

  def date
    start.strftime('%Y年%m月%d日') + " #{ja_day}"
  end

  def ja_day
    en_day = start.strftime('%A')

    "(#{DAYS[en_day]})"
  end

  DAYS = {
    'Sunday' => '日',
    'Monday' => '月',
    'Tuesday' => '火',
    'Wednesday' => '水',
    'Thursday' => '木',
    'Friday' => '金',
    'Saturday' => '土'
  }.freeze
end
