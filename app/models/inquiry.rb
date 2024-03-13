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

  enum :referrer, 'チラシ' => 0,
                  '口コミ' => 1,
                  'ホームページ' => 2,
                  '看板' => 3,
                  '資料' => 4,
                  'その他' => 5

  scope :setsumeikai, -> { where(category: 'R') }
  scope :general, -> { where(category: 'I') }

  def to_gas_api
    {
      id: id,
      category: category,
      created_at: created_at.strftime('%Y-%m-%d'),
      name_child: child_name,
      name: parent_name,
      tel: phone,
      email: email,
      body: requests || '',
      birth: gas_birth,
      kinder_attend: kindy,
      primary_attend: ele_school,
      start_season: start_date,
      school_name: setsumeikai_school,
      trigger: referrer,
      age: child_grade,
      event_schedule: event_schedule
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

  def before_new_school_year?
    Time.zone.today.month < 4 || (Time.zone.today.month == 4 && Time.zone.today.day < 1)
  end

  def born_after_school_start?
    (child_birthday.month > 3 && child_birthday.day > 1) || child_birthday.month > 4
  end

  def child_grade
    return '' if child_birthday.nil?

    age = Time.zone.now.year - child_birthday.year
    age -= 1 if born_after_school_start?
    age -= 1 if before_new_school_year?

    YEAR_AGE_MAP[age] || ''
  end

  def event_schedule
    return { date: '', time: '' } unless setsumeikai

    {
      date: setsumeikai.start.strftime('%Y-%m-%d'),
      time: setsumeikai.start.strftime('%H:%M')
    }
  end

  def gas_birth
    return '' if child_birthday.nil?

    child_birthday.strftime('%Y-%m-%d')
  end

  def setsumeikai_school
    return '' unless setsumeikai

    setsumeikai.school.name
  end

  CATEGORY_MAP = {
    'C' => 'Call center',
    'I' => '問合せ',
    'R' => '説明会'
  }.freeze

  YEAR_AGE_MAP = {
    1 => '満１歳',
    2 => '満２歳',
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
