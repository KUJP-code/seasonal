# frozen_string_literal: true

class Inquiry < ApplicationRecord
  VALID_CATEGORIES = %w[C I R].freeze

  belongs_to :setsumeikai, counter_cache: true, optional: true
  belongs_to :school, optional: true

  validates :category, length: { is: 1 }
  validates :category, inclusion: { in: VALID_CATEGORIES }

  enum :referrer, 'チラシ' => 0,
                  '口コミ' => 1,
                  'ホームページ' => 2,
                  '看板' => 3,
                  '資料' => 4,
                  'その他' => 5

  scope :setsumeikai, -> { where(category: 'R') }
  scope :general, -> { where(category: 'I') }

  def setsumeikai_school
    setsumeikai.school.name
  end

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
      kinder_attend: kindy,
      primary_attend: ele_school,
      start_season: start_date,
      school_name: setsumeikai_school,
      trigger: referrer,
      age: child_age,
      event_schedule: event_schedule
    }
  end

  def child_age
    YEAR_AGE_MAP[Time.zone.now.year - child_birthday.year] || ''
  end

  def to_gas_update
    {
      category: CATEGORY_MAP[category],
      id: id.to_s,
      target: child_name
    }
  end

  private

  def event_schedule
    {
      date: setsumeikai.start.strftime('%Y-%m-%d'),
      time: setsumeikai.start.strftime('%H:%M')
    }
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
    6 => '小１',
    7 => '小２',
    8 => '小３',
    9 => '小４',
    10 => '小５',
    11 => '小６',
    12 => '中学１年',
    13 => '中学２年',
    14 => '高校生以上'
  }.freeze
end
