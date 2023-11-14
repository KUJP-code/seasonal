# frozen_string_literal: true

class Setsumeikai < ApplicationRecord
  belongs_to :school
  has_many :inquiries, dependent: nil
  has_many :setsumeikai_involvements, dependent: :destroy
  accepts_nested_attributes_for :setsumeikai_involvements,
                                allow_destroy: true,
                                reject_if: :all_blank
  has_many :involved_schools, through: :setsumeikai_involvements,
                              source: :school

  validates :start, :attendance_limit, :release_date, presence: true
  validates :attendance_limit, comparison: { greater_than_or_equal_to: 0 }
  validates :start, comparison: { greater_than: Time.zone.now }
  validates :release_date, comparison: { less_than: :start }
  validate :host_school_involved

  scope :upcoming, -> { where('start > ?', Time.zone.now) }
  scope :visible, -> { where('release_date < ?', Time.zone.now) }
  scope :calendar, -> { upcoming.visible }

  def as_json(_options = {})
    {
      id: id.to_s,
      start: start,
      title: school.name
    }
  end

  def date
    start.strftime('%Y年%m月%d日') + " #{ja_day}"
  end

  def date_time
    "#{date} #{start.strftime('%H:%M')}"
  end

  def ja_day
    en_day = start.strftime('%A')

    "(#{DAYS[en_day]})"
  end

  def school_date_time
    "#{school.name} #{date} #{start.strftime('%H:%M')}"
  end

  private

  def host_school_involved
    return if setsumeikai_involvements.map(&:school_id).include?(school_id)

    errors.add(:setsumeikai_involvements, '説明会会場を含まなければならない。')
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
