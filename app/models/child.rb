# frozen_string_literal: true

class Child < ApplicationRecord
  # Set names, kindy from attr_accessors
  before_validation :set_name, :set_kana, :set_kindy

  # Allow use of separate fields to ensure consistent name formatting
  attr_accessor :first_name, :family_name, :kana_first, :kana_family

  belongs_to :parent, class_name: 'User', optional: true, inverse_of: :children
  belongs_to :school, optional: true
  has_many :upcoming_events, through: :school,
                             class_name: 'Event'
  has_one :regular_schedule, dependent: :destroy
  delegate :area, to: :school

  has_many :registrations, dependent: :destroy
  accepts_nested_attributes_for :registrations
  has_many :time_slots, through: :registrations,
                        source: :registerable,
                        source_type: 'TimeSlot'
  has_many :options, through: :registrations,
                     source: :registerable,
                     source_type: 'Option'
  has_many :invoices, dependent: :destroy
  has_many :real_invoices, -> { real },
           class_name: 'Invoice',
           dependent: nil,
           inverse_of: :child
  has_many :events, -> { distinct }, through: :invoices
  has_many :adjustments, through: :invoices
  has_many :survey_responses, dependent: nil

  # Track changes with PaperTrail
  has_paper_trail

  # Allow export/import with postgres-copy
  acts_as_copy_target

  enum :category, internal: 0,
                  reservation: 1,
                  external: 2,
                  unknown: 3,
                  default: :external

  enum :grade, '満１歳' => 0,
               '満２歳' => 1,
               '年々少' => 2,
               '年少' => 3,
               '年中' => 4,
               '年長' => 5,
               '小１' => 6,
               '小２' => 7,
               '小３' => 8,
               '小４' => 9,
               '小５' => 10,
               '小６' => 11,
               '中学１年' => 12,
               '中学２年' => 13,
               '高校生以上' => 14

  enum :photos, 'NG' => 0,
                'マイページOK' => 1,
                'OK' => 3,
                'Unknown' => 4

  validates :katakana_name, format: { with: /\A[ァ-ヶヶ　ー ]+\z/ }
  validates :allergies, :category, :en_name, :grade, :katakana_name, :name, :photos, presence: true
  validates :ssid, uniqueness: { allow_blank: true }

  def arrival_time(slot)
    arr_opt = options.find_by(optionable: slot, category: :arrival)
    return slot.start_time.strftime('%I:%M%p') if arr_opt.nil?

    (slot.start_time + arr_opt.modifier.minutes).strftime('%I:%M%p')
  end

  def departure_time(slot)
    dep_opt = options.find_by(optionable: slot, category: :departure)
    return slot.end_time.strftime('%I:%M%p') if dep_opt.nil?

    (slot.end_time + dep_opt.modifier.minutes).strftime('%I:%M%p')
  end

  def diff_school_events
    events.where.not(school:).distinct
  end

  def hat_adjustment?
    adjustments.find_by(reason: '帽子代(野外アクティビティに参加される方でKids UP帽子をお持ちでない方のみ)',
                        change: 1_100).present?
  end

  def names_string
    "#{name}, #{katakana_name}, #{en_name}"
  end

  def next_event
    upcoming_events.first
  end

  def member?
    return false if external?

    true
  end

  def registered?(registerable)
    return true if registrations.find_by(registerable_id: registerable.id,
                                         registerable_type: registerable.class.name)

    false
  end

  def siblings
    return [] if parent.nil?

    parent.children.excluding(self)
  end

  private

  def set_kana
    # Guard clause should never happen in prod because required field, but does
    # when directly modifying after creation in seeds file
    return if kana_first.nil? && kana_family.nil?

    self.katakana_name = [kana_family.strip, kana_first.strip].join(' ')
  end

  def set_kindy
    self.kindy = %w[満１歳 満２歳 年々少 年少 年中 年長].include?(grade)
  end

  def set_name
    # Guard clause should never happen in prod because required field, but does
    # when directly modifying after creation in seeds file
    return if first_name.nil? && family_name.nil?

    self.name = [family_name.strip, first_name.strip].join(' ')
  end
end
