# frozen_string_literal: true

class Inquiry < ApplicationRecord
  VALID_CATEGORIES = %w[C I R].freeze

  belongs_to :setsumeikai, counter_cache: true, optional: true
  belongs_to :school
  delegate :area, to: :school

  validates :parent_name, :phone, :email, presence: true
  validates :privacy_policy, acceptance: { accept: 'on' }
  validates :category,
            presence: true,
            length: { is: 1 },
            inclusion: { in: VALID_CATEGORIES }
  validate :setsumeikai_open_for_inquiry, if: -> { category == 'R' }
  enum :referrer, 'チラシ' => 0,
                  '口コミ' => 1,
                  'ホームページ' => 2,
                  '看板' => 3,
                  '資料' => 4,
                  'その他' => 5

  scope :setsumeikai, -> { where(category: 'R') }
  scope :general, -> { where(category: 'I') }

  def child_grade
    return '' if child_birthday.nil?

    school_age = Time.zone.now.year - child_birthday.year
    school_age -= 1 if born_after_school_start?
    school_age -= 1 if before_new_school_year?
    return "#{calendar_age}歳" if school_age < 3

    SCHOOL_AGE_MAP[school_age] || ''
  end

  def to_gas_api
    {
      id:,
      category:,
      created_at: created_at.strftime('%Y-%m-%d'),
      name_child: child_name,
      name: parent_name,
      tel: phone,
      email:,
      body: requests || '',
      birth: gas_birth,
      kinder_attend: kindy,
      primary_attend: ele_school,
      start_season: start_date,
      school_name: setsumeikai_school,
      trigger: referrer,
      age: child_grade,
      event_schedule:
    }
  end

  def to_gas_update
    {
      category: CATEGORY_MAP[category],
      id: id.to_s,
      target: child_name || ''
    }
  end

  private

  def before_birthday?
    current_month = Time.zone.today.month
    current_month < child_birthday.month ||
      (current_month == child_birthday.month &&
        Time.zone.now.day < child_birthday.day)
  end

  def before_new_school_year?
    current_month = Time.zone.today.month
    current_month < 4 ||
      (current_month == 4 && Time.zone.today.day < 1)
  end

  def born_after_school_start?
    (child_birthday.month > 3 && child_birthday.day > 1) ||
      child_birthday.month > 4
  end

  def event_schedule
    return { date: '', time: '' } unless setsumeikai

    { date: setsumeikai.start.strftime('%Y-%m-%d'),
      time: setsumeikai.start.strftime('%H:%M') }
  end

  def gas_birth
    return '' if child_birthday.nil?

    child_birthday.strftime('%Y-%m-%d')
  end

  def calendar_age
    age = Time.zone.now.year - child_birthday.year
    age -= 1 if before_birthday?
    age
  end

  def setsumeikai_school
    return '' unless setsumeikai

    setsumeikai.school.name
  end

  def setsumeikai_open_for_inquiry
    return if setsumeikai.nil?

    return unless setsumeikai.full?

    errors.add(:setsumeikai_id, '申し込みは締め切られました。')
  end
  CATEGORY_MAP = {
    'C' => 'Call center',
    'I' => '問合せ',
    'R' => '説明会'
  }.freeze

  SCHOOL_AGE_MAP = {
    3 => '年少',
    4 => '年中',
    5 => '年長',
    6 => '小学１年生',
    7 => '小学２年生',
    8 => '小学３年生',
    9 => '小学４年生',
    10 => '小学５年生',
    11 => '小学６年生',
    12 => '中学１年生',
    13 => '中学２年生',
    14 => '中学３年生',
    15 => '高校生以上'
  }.freeze
end
